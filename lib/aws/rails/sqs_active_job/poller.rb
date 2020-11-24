# frozen_string_literal: true

require 'aws-sdk-sqs'
require 'optparse'
require 'concurrent'

module Aws
  module Rails
    module SqsActiveJob

      class Interrupt < Exception; end

      # CLI runner for polling for SQS ActiveJobs
      # Use `aws_sqs_active_job --help` for detailed usage
      class Poller

        DEFAULT_OPTS = {
          threads: Concurrent.processor_count,
          max_messages: 10,
          visibility_timeout: 60,
          shutdown_timeout: 15,
        }

        def initialize(args = ARGV)
          @options = parse_args(args)
          # Set_environment must be run before we boot_rails
          set_environment
        end

        def set_environment
          @environment = @options[:environment] || ENV["APP_ENV"] || ENV["RAILS_ENV"] || ENV["RACK_ENV"] || "development"
        end

        def run
          # exit 0
          boot_rails

          # cannot load config (from file or initializers) until after
          # rails has been booted.
          @options = DEFAULT_OPTS
                     .merge(Aws::Rails::SqsActiveJob.config.to_h)
                     .merge(@options)
          validate_config
          # ensure we have a logger configured
          @logger = @options[:logger] || ActiveSupport::Logger.new(STDOUT)
          @logger.info("Starting Poller with options=#{@options}")


          Signal.trap('INT') { raise Interrupt }
          Signal.trap('TERM') { raise Interrupt }
          @executor = Executor.new(max_threads: @options[:threads], logger: @logger, max_queue: @options[:backpressure])

          poll
        rescue Interrupt
          @logger.info 'Process Interrupted or killed - attempting to shutdown cleanly.'
          shutdown
          exit
        end

        private

        def shutdown
          @executor.shutdown(@options[:shutdown_timeout])
        end

        def poll
          queue_url = Aws::Rails::SqsActiveJob.config.queue_url_for(@options[:queue])
          @logger.info "Polling on: #{@options[:queue]} => #{queue_url}"
          client = Aws::Rails::SqsActiveJob.config.client
          @poller = Aws::SQS::QueuePoller.new(queue_url, client: client)
          single_message = @options[:max_messages] == 1
          poller_options = {
            skip_delete: true,
            max_number_of_messages: @options[:max_messages],
            visibility_timeout: @options[:visibility_timeout]
          }
          @poller.poll(poller_options) do |msgs|
            msgs = [msgs] if single_message
            @logger.info "Processing batch of #{msgs.length} messages"
            msgs.each do |msg|
              @executor.execute(Aws::SQS::Message.new(
                queue_url: queue_url,
                receipt_handle: msg.receipt_handle,
                data: msg,
                client: client
              ))
            end
          end
        end

        def boot_rails
          ENV['RACK_ENV'] = ENV['RAILS_ENV'] = @environment
          require "rails"
          require File.expand_path("config/environment.rb")
        end

        def parse_args(argv)
          opts = {}
          @parser = option_parser
          @parser.parse!(argv, into: opts)
          opts
        end

        def option_parser
          parser = ::OptionParser.new { |opts|
            opts.on "-q", "--queue STRING", "[Required] Queue to poll"
            opts.on "-e", "--environment STRING", "Rails environment (defaults to development). You can also use the APP_ENV or RAILS_ENV environment variables to specify the environment."
            opts.on "-t", "--threads INTEGER", Integer, "The maximum number of worker threads to create.  Defaults to the number of processors available on this system."
            opts.on "-b", "--backpressure INTEGER", Integer, "The maximum number of messages to have waiting in the Executor queue. This should be a low, but non zero number.  Messages in the Executor queue cannot be picked up by other processes and will slow down shutdown."
            opts.on "-m", "--max_messages INTEGER", Integer, "Max number of messages to receive in a batch from SQS."
            opts.on "-v", "--visibility_timeout INTEGER", Integer, "The visibility timeout is the number of seconds that a message will not be processable by any other consumers. You should set this value to be longer than your expected job runtime to prevent other processes from picking up an running job.  See the SQS Visibility Timeout Documentation at https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-visibility-timeout.html."
            opts.on "-s", "--shutdown_timeout INTEGER", Integer, "The amount of time to wait for a clean shutdown.  Jobs that are unable to complete in this time will not be deleted from the SQS queue and will be retryable after the visibility timeout."
          }

          parser.banner = "aws_sqs_active_job [options]"
          parser.on_tail "-h", "--help", "Show help" do
            puts parser
            exit 1
          end

          parser
        end

        def validate_config
          raise ArgumentError, 'You must specify the name of the queue to process jobs from' unless @options[:queue]
        end
      end
    end
  end
end