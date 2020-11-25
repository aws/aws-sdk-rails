# frozen_string_literal: true

require 'aws-sdk-sqs'

module ActiveJob
  module QueueAdapters

    class AmazonSqsAdapter

      def enqueue(job)
        _enqueue(job)
      end

      def enqueue_at(job, timestamp)
        delay = (timestamp - Time.now.to_f).floor
        raise ArgumentError, 'Unable to queue a job with a delay great than 15 minutes' if delay > 15.minutes
        _enqueue(job, delay_seconds: delay)
      end

      private

      def _enqueue(job, send_message_opts = {})
        body = job.serialize
        queue_url = Aws::Rails::SqsActiveJob.config.queue_url_for(job.queue_name)
        send_message_opts[:queue_url] = queue_url
        send_message_opts[:message_body] = Aws::Json.dump(body)
        send_message_opts[:message_attributes] = message_attributes(job)
        Aws::Rails::SqsActiveJob.config.client.send_message(send_message_opts)
      end

      def message_attributes(job)
        {
          'aws_sqs_active_job_class' => {
            string_value: job.class.to_s,
            data_type: 'String'
          },
          'aws_sqs_active_job_version' => {
            string_value: Aws::Rails::VERSION,
            data_type: 'String'
          }
        }
      end
    end

    # create an alias to allow `:amazon` to be used as the adapter name
    # `:amazon` is the convention used for ActionMailer and ActiveStorage
    AmazonAdapter = AmazonSqsAdapter
  end
end