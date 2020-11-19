# frozen_string_literal: true

require 'concurrent'

module Aws
  module Rails
    module SqsActiveJob
      # CLI runner for polling for SQS ActiveJobs
      class Executor

        DEFAULT_EXECUTOR_OPTIONS = {
           min_threads:     0,
           max_threads:     Concurrent.processor_count,
           auto_terminate:  true,
           idletime:        60, # 1 minute
           max_queue:       2,
           fallback_policy: :caller_runs # slow down the produced thread
        }.freeze

        def initialize(options = {})
          @executor = Concurrent::ThreadPoolExecutor.new(DEFAULT_EXECUTOR_OPTIONS.merge(options))
          @logger = options[:logger] || ActiveSupport::Logger.new(STDOUT)
        end

        # Push processing
        # TODO: Consider catching the exception and sleeping instead of using :caller_runs
        def push(message)
          @executor.post(message) do |message|
            begin
              JobRunner.new(message).perform
              message.delete
            rescue StandardError => e
              @logger.info "Error processing job: #{e}"
            end
          end
        end

        def shutdown(timeout=nil)
          @executor.shutdown
          clean_shutdown = @executor.wait_for_termination(timeout)
          if clean_shutdown
            @logger.info 'Clean shutdown complete.  All executing jobs finished.'
          else
            @logger.info "Timeout (#{timeout}) exceeded.  Some jobs may not have"\
              " finished cleanly.  Unfinished jobs will not be removed from"\
              " the queue and can be ru-run once their visibility timeout"\
              " passes."
          end
        end
      end
    end
  end
end