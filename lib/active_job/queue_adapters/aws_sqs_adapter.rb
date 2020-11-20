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
        @client = Aws::Rails::SqsActiveJob.config.client
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
        queue_url = Aws::Rails::SqsActiveJob.config.queue_url_for(job.queue_name)
        send_message_opts[:queue_url] = queue_url
        send_message_opts[:message_body] = Aws::Json.dump(body)
        @client.send_message(send_message_opts)
      end
    end
  end
end