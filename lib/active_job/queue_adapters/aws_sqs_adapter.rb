# frozen_string_literal: true

require "securerandom"
require "concurrent/scheduled_task"
require "concurrent/executor/thread_pool_executor"
require "concurrent/utility/processor_counter"

require 'aws-sdk-sqs'

module ActiveJob
  module QueueAdapters

    class AwsSqsAdapter
      def initialize(**executor_options)
        @client = Aws::Rails::SqsJob.config.client

        # config.active_job.queue_name_prefix
        # config.active_job.queue_name_delimiter
      end

      def enqueue(job)
        body = job.serialize
        queue_url = Aws::Rails::SqsJob.config.queue_url_for(job.queue_name)
        puts "#{job.queue_name} => #{queue_url}"
        @client.send_message(queue_url: queue_url, message_body: Aws::Json.dump(body))
      end

      def enqueue_at(job, timestamp)
        # TODO: Check for max timeout.
      end

      # Gracefully stop processing jobs. Finishes in-progress work and handles
      # any new jobs following the executor's fallback policy (`caller_runs`).
      # Waits for termination by default. Pass `wait: false` to continue.
      def shutdown(wait: true)
      puts "MY SHUTDOWN"
      # TODO: Determine if other shutdown is required. None should be...
      end


      class Scheduler #:nodoc:
        DEFAULT_EXECUTOR_OPTIONS = {
                                     min_threads:     0,
                                     max_threads:     Concurrent.processor_count,
                                     auto_terminate:  true,
                                     idletime:        60, # 1 minute
                                     max_queue:       0, # unlimited
                                     fallback_policy: :caller_runs # shouldn't matter -- 0 max queue
                                   }.freeze

        attr_accessor :immediate

        def initialize(**options)
          self.immediate = false
          @immediate_executor = Concurrent::ImmediateExecutor.new
          @async_executor = Concurrent::ThreadPoolExecutor.new(DEFAULT_EXECUTOR_OPTIONS.merge(options))
        end

        def enqueue(job, queue_name:)
          executor.post(job, &:perform)
        end

        def enqueue_at(job, timestamp, queue_name:)
          delay = timestamp - Time.current.to_f
          if delay > 0
            Concurrent::ScheduledTask.execute(delay, args: [job], executor: executor, &:perform)
          else
            enqueue(job, queue_name: queue_name)
          end
        end

        def shutdown(wait: true)
          @async_executor.shutdown
          @async_executor.wait_for_termination if wait
        end

        def executor
          immediate ? @immediate_executor : @async_executor
        end
      end
    end
  end
end