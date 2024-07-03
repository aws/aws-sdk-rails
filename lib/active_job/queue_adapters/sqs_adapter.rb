# frozen_string_literal: true

require 'aws-sdk-sqs'

module ActiveJob
  module QueueAdapters
    class SqsAdapter
      def enqueue_after_transaction_commit?
        true
      end

      def enqueue(job)
        _enqueue(job)
      end

      def enqueue_at(job, timestamp)
        delay = Params.assured_delay_seconds(timestamp)
        _enqueue(job, nil, delay_seconds: delay)
      end

      def enqueue_all(jobs)
        enqueued_count = 0
        jobs.group_by(&:queue_name).each do |queue_name, same_queue_jobs|
          queue_url = Aws::Rails::SqsActiveJob.config.queue_url_for(queue_name)
          base_send_message_opts = { queue_url: queue_url }

          same_queue_jobs.each_slice(10) do |chunk|
            entries = chunk.map do |job|
              entry = Params.new(job, nil).entry
              entry[:id] = job.job_id
              entry[:delay_seconds] = Params.assured_delay_seconds(job.scheduled_at) if job.scheduled_at
              entry
            end

            send_message_opts = base_send_message_opts.deep_dup
            send_message_opts[:entries] = entries

            send_message_batch_result = Aws::Rails::SqsActiveJob.config.client.send_message_batch(send_message_opts)
            enqueued_count += send_message_batch_result.successful.count
          end
        end
        enqueued_count
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
  end
end
