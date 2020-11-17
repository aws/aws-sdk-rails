# frozen_string_literal: true

module Aws
  module Rails
    module SqsJob

      def self.config
        @config ||= Configuration.new
      end

      def self.configure
        yield(config)
      end

      class Configuration

        # Default configuration options
        DEFAULTS = {
          key_1: 'test'
        }

        # @return [Array[Hash[Symbol, String]]]Queues
        # TODO: docs...
        attr_accessor :queues

        # @option options [Array[Hash[Symbol, String]]] :queues
        # @option options [String] :config_file
        # @option options [SQS::Client] :client
        def initialize(options = {})
          options[:config_file] ||= config_file if config_file.exist?
          @options = default_options.merge(
            file_options(options).merge(options.deep_symbolize_keys)
          )
          set_attributes(@options)
        end

        def client
          @client ||= @options[:client] || Aws::SQS::Client.new
        end


        # Return the queue_url for a given job_queue name
        # Queues in Config can be defined as either a url, arn or just name.
        # For ARNs and names, an additional service call is required to
        # lookup the queue url.
        # This method is syncronized to ensure multiple client calls are not
        # made to look up the same queue url.
        def queue_url_for(job_queue)
          job_queue = job_queue.to_sym
          raise ArgumentError, "No queue defined for #{job_queue}" unless queues.key? job_queue

          queues[job_queue.to_sym]
        end

        private

        # Set accessible attributes after merged options.
        def set_attributes(options)
          @options.keys.each do |opt_name|
            instance_variable_set("@#{opt_name}", options[opt_name])
          end
        end

        # @return [Hash] Default options.
        def default_options
          DEFAULTS
        end

        def file_options(options = {})
          file_path = config_file_path(options)
          if file_path
            load_from_file(file_path)
          else
            {}
          end
        end

        def config_file
          file = ::Rails.root.join("config/sqs_job/#{::Rails.env}.yml")
          file = ::Rails.root.join('config/sqs_job.yml') unless file.exist?
          file
        end


        # Load options from YAML file
        def load_from_file(file_path)
          puts "Loading config form: #{file_path}"
          require "erb"
          opts = YAML.load(ERB.new(File.read(file_path)).result) || {}
          opts.deep_symbolize_keys
        end

        # @return [String] Configuration path found in environment or YAML file.
        def config_file_path(options)
          options[:config_file] || ENV["AWS_SQS_JOB_CONFIG_FILE"]
        end
      end
    end
  end
end