# frozen_string_literal: true

require 'aws-sdk-sqs'
require 'optparse'

module Aws
  module Rails
    module SqsJob
      # CLI runner for polling for SQS ActiveJobs

      class Interrupt < Exception; end
      class Poller

        DEFAULT_OPTS = {
          threads: Concurrent.processor_count,
          max_messages: 10,
          visibility_timeout: 60,
          shutdown_timeout: 15
        }

        def initialize(args = ARGV)
          # parse arguments and merge config, ect
          @options = parse_args(args)
          validate_config
          puts "Parsed options to: #{@options}"
          set_environment
        end

        def set_environment
          @environment = @options[:environment] || ENV["APP_ENV"] || ENV["RAILS_ENV"] || ENV["RACK_ENV"] || "development"
        end

        def run
          # exit 0
          boot_rails

          Signal.trap('INT') { raise Interrupt }
          # Signal.trap('TERM') { shutdown; exit }
          @executor = Executor.new(max_threads: @options[:threads])

          poll
        rescue Interrupt
          puts 'Process Interrupted or killed - attempting to shutdown cleanly.'
          shutdown
          exit
        end

        def shutdown
          @executor.shutdown(@options[:shutdown_timeout])
          puts 'Jobs have completed cleanly. Shutdown complete.'
        end

        def poll
          queue_url = Aws::Rails::SqsJob.config.queue_url_for(@options[:queue])
          puts "Polling on: #{@options[:queue]} => #{queue_url}"
          client = Aws::Rails::SqsJob.config.client
          @poller = Aws::SQS::QueuePoller.new(queue_url, client: client)
          single_message = @options[:max_messages] == 1
          poller_options = {
            skip_delete: true,
            max_number_of_messages: @options[:max_messages],
            visibility_timeout: @options[:visibility_timeout]
          }
          @poller.poll(poller_options) do |msgs|
            msgs = [msgs] if single_message
            puts "Processing batch of #{msgs.length} messages"
            msgs.each do |msg|
              @executor.push(Aws::SQS::Message.new(
                queue_url: queue_url,
                receipt_handle: msg.receipt_handle,
                data: msg,
                client: client
              ))
            end
          end
        end

        private
        def boot_rails
          ENV["RACK_ENV"] = ENV["RAILS_ENV"] = @environment
          require "rails"
          require File.expand_path("config/environment.rb")
        end

        def parse_args(argv)
          opts = DEFAULT_OPTS.dup
          @parser = option_parser
          @parser.parse!(argv, into: opts)
          opts
        end

        def option_parser
          parser = ::OptionParser.new { |opts|
            opts.on "-e", "--environment ENV", "Rails environment"
            opts.on "-q", "--queue QUEUE", "[Required] Queue to poll"
            opts.on "-t", "--threads [INTEGER]", "Number of worker threads"
            opts.on "-m", "--max_messages [INTEGER]", "Max number of messages to receive at once."
            opts.on "-V", "--visibility_timeout [INTEGER]", "Visibility timeout"
            opts.on "-s", "--shutdown_timeout [INTEGER]", "Shutdown timeout"
            opts.on "-v", "--[no-]verbose", "Print more verbose output"
          }

          parser.banner = "aws_sdk_job_poll [options]"
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