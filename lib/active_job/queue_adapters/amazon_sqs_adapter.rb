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
        _enqueue(job, nil, delay_seconds: delay)
      end

      private

      def _enqueue(job, body = nil, send_message_opts = {})
        body ||= job.serialize
        queue_url = Aws::Rails::SqsActiveJob.config.queue_url_for(job.queue_name)
        send_message_opts[:queue_url] = queue_url
        send_message_opts[:message_body] = Aws::Json.dump(body)
        send_message_opts[:message_attributes] = message_attributes(job)

        if Aws::Rails::SqsActiveJob.fifo?(queue_url)
          send_message_opts[:message_deduplication_id] =
            Digest::SHA256.hexdigest(Aws::Json.dump(deduplication_body(job, body)))

          message_group_id = job.message_group_id if job.respond_to?(:message_group_id)
          message_group_id ||= Aws::Rails::SqsActiveJob.config.message_group_id

          send_message_opts[:message_group_id] = message_group_id
        end

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

      def deduplication_body(job, body)
        dedup_keys = job.deduplication_keys if job.respond_to?(:deduplication_keys)
        dedup_keys ||= Aws::Rails::SqsActiveJob.config.deduplication_keys.map(&:to_s)

        ignored_dedup_key = 'job_id'

        if dedup_keys.include?(ignored_dedup_key)
          dedup_keys.delete(ignored_dedup_key)
          Rails.logger.warn <<~WARNING
            job_id cannot be used as a key for deduplication.
            It is ignored to ensure run-once behavior of ActiveJob retries.
          WARNING
        end

        dedup_keys = body.except(ignored_dedup_key).keys if dedup_keys.blank?

        body.slice(*dedup_keys)
      end
    end

    # create an alias to allow `:amazon` to be used as the adapter name
    # `:amazon` is the convention used for ActionMailer and ActiveStorage
    AmazonAdapter = AmazonSqsAdapter
  end
end
