# frozen_string_literal: true

require 'aws-sdk-sqs'

module Aws
  module Rails
    # CLI runner for polling for SQS ActiveJobs
    class SqsJobPollCli

      attr_reader :environment

      def initialize(options = {})
        # parse arguments and merge config, ect
        @options = options
        set_environment(nil)
      end

      def set_environment(cli_env)
        # See #984 for discussion.
        # APP_ENV is now the preferred ENV term since it is not tech-specific.
        # Both Sinatra 2.0+ and Sidekiq support this term.
        # RAILS_ENV and RACK_ENV are there for legacy support.
        @environment = cli_env || ENV["APP_ENV"] || ENV["RAILS_ENV"] || ENV["RACK_ENV"] || "development"
      end

      def run
        boot_rails
        puts "Here we are.  In rails."
        queue_url = 'https://sqs.us-west-2.amazonaws.com/655347895545/TestQueue'
        poller = Aws::SQS::QueuePoller.new(queue_url)
        poller.poll(skip_delete: true) do |msg|
          body = Aws::Json.load(msg.body)
          job_class = body["job_class"].constantize
          job = job_class.new
          job.perform(body["arguments"])
          poller.delete_message(msg) # if successful
        end
      end

      private
      def boot_rails
        ENV["RACK_ENV"] = ENV["RAILS_ENV"] = environment
        require "rails"
        require File.expand_path("config/environment.rb")
      end

      def parse_options(argv)
        opts = {}
        @parser = option_parser(opts)
        @parser.parse!(argv)
        opts
      end

      def option_parser(opts)
        parser = OptionParser.new { |o|
          o.on "-e", "--environment ENV", "Rails environment" do |arg|
            opts[:environment] = arg
          end
          o.on "-v", "--verbose", "Print more verbose output" do |arg|
            opts[:verbose] = arg
          end

          o.on "-C", "--config PATH", "path to YAML config file" do |arg|
            opts[:config_file] = arg
          end
        }

        parser.banner = "aws_sdk_job_poll [options]"
        parser.on_tail "-h", "--help", "Show help" do
          logger.info parser
          exit 1
        end

        parser
      end

    end
  end
end