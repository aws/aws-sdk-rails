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
          @queue_urls = {}
          @queue_urls_mutex = Mutex.new
        end

        def client
          @client ||= @options[:client] || Aws::SQS::Client.new
        end


        # TODO: This is threadsafe, but could be improved
        def queue_url_for(job_queue)
          job_queue = job_queue.to_sym
          @queue_urls_mutex.synchronize do
            return @queue_urls[job_queue] if @queue_urls.key? job_queue

            # can be a name, url, or arn
            queue_def = queues[job_queue.to_sym]

            raise ArgumentError, "No queue defined for #{job_queue}" unless queue_def

            if queue_def.include?('://')
              @queue_urls[job_queue] = queue_def
              return queue_def
            elsif queue_def.start_with?('arn:')
              raise NotImplementedError, 'TODO: Support me!'
            else
              @queue_urls[job_queue] = client.get_queue_url(queue_name: queue_def).queue_url
              return @queue_urls[job_queue]
            end
          end
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