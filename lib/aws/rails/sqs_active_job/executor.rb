# frozen_string_literal: true

require 'concurrent'

module Aws
  module Rails
    module SqsActiveJob
      # CLI runner for polling for SQS ActiveJobs
      class Executor
        DEFAULTS = {
          min_threads: 0,
          max_threads: Concurrent.processor_count,
          auto_terminate: true,
          idletime: 60, # 1 minute
          fallback_policy: :abort # Concurrent::RejectedExecutionError must be handled
        }.freeze

        def initialize(options = {})
          @executor = Concurrent::ThreadPoolExecutor.new(DEFAULTS.merge(options))
          @retry_standard_errors = options[:retry_standard_errors]
          @logger = options[:logger] || ActiveSupport::Logger.new($stdout)
          @task_complete = Concurrent::Event.new
        end

        def execute(message)
          begin
            @executor.post(message) do |message|
            job = JobRunner.new(message)
            @logger.info("Running job: #{job.id}[#{job.class_name}]")
            job.run
            message.delete
          rescue Aws::Json::ParseError => e
            @logger.error "Unable to parse message body: #{message.data.body}. Error: #{e}."
          rescue StandardError => e
            job_msg = job ? "#{job.id}[#{job.class_name}]" : 'unknown job'
            @logger.info "Error processing job #{job_msg}: #{e}"
            @logger.debug e.backtrace.join("\n")

            if @retry_standard_errors && !job.exception_executions?
              @logger.info(
                'retry_standard_errors is enabled and job has not ' \
                "been retried by Rails.  Leaving #{job_msg} in the queue."
              )
            else
              message.delete
            end
            ensure
              @task_complete.set
            end
          rescue Concurrent::RejectedExecutionError
            # no capacity, wait for a task to complete
            @task_complete.reset
            @task_complete.wait
            retry
          end
        end

        def shutdown(timeout = nil)
          @executor.shutdown
          clean_shutdown = @executor.wait_for_termination(timeout)
          if clean_shutdown
            @logger.info 'Clean shutdown complete.  All executing jobs finished.'
          else
            @logger.info "Timeout (#{timeout}) exceeded.  Some jobs may not have " \
                         'finished cleanly.  Unfinished jobs will not be removed from ' \
                         'the queue and can be ru-run once their visibility timeout ' \
                         'passes.'
          end
        end
      end
    end
  end
end
