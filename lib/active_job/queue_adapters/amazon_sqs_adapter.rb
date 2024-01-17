# frozen_string_literal: true

require 'aws-sdk-sqs'

module ActiveJob
  module QueueAdapters
    class AmazonSqsAdapter
      def enqueue(job)
        _enqueue(job)
      end

      def enqueue_at(job, timestamp)
        delay = Params.assured_delay_seconds(timestamp)
        _enqueue(job, nil, delay_seconds: delay)
      end

      private

      def _enqueue(job, body = nil, send_message_opts = {})
        body ||= job.serialize
        params = Params.new(job, body)
        send_message_opts = send_message_opts.merge(params.entry)
        send_message_opts[:queue_url] = params.queue_url

        Aws::Rails::SqsActiveJob.config.client.send_message(send_message_opts)
      end
    end

    # create an alias to allow `:amazon` to be used as the adapter name
    # `:amazon` is the convention used for ActionMailer and ActiveStorage
    AmazonAdapter = AmazonSqsAdapter
  end
end
