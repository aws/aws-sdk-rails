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
      end

      def enqueue(job)
        _enqueue(job)
      end

      def enqueue_at(job, timestamp)
        delay = (timestamp - Time.now.to_f).floor
        raise 'Unable to queue a job with a delay great than 15 minutes' if delay > 15.minutes
        _enqueue(job, delay_seconds: delay)
      end

      private

      def _enqueue(job, send_message_opts = {})
        body = job.serialize
        queue_url = Aws::Rails::SqsJob.config.queue_url_for(job.queue_name)
        puts "#{job.queue_name} => #{queue_url}"
        send_message_opts[:queue_url] = queue_url
        send_message_opts[:message_body] = Aws::Json.dump(body)
        @client.send_message(send_message_opts)
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