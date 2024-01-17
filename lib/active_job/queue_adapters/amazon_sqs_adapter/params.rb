# frozen_string_literal: true

module ActiveJob
  module QueueAdapters
    class AmazonSqsAdapter
      # == build request parameter of Aws::SQS::Client
      class Params
        def initialize(job, body)
          @job = job
          @body = body || job.serialize
        end

        def queue_url
          @queue_url ||= Aws::Rails::SqsActiveJob.config.queue_url_for(@job.queue_name)
        end

        def entry
          if Aws::Rails::SqsActiveJob.fifo?(queue_url)
            default_entry.merge(options_for_fifo)
          else
            default_entry
          end
        end

        private

        def default_entry
          {
            message_body: Aws::Json.dump(@body),
            message_attributes: message_attributes
          }
        end

        def message_attributes
          {
            'aws_sqs_active_job_class' => {
              string_value: @job.class.to_s,
              data_type: 'String'
            },
            'aws_sqs_active_job_version' => {
              string_value: Aws::Rails::VERSION,
              data_type: 'String'
            }
          }
        end

        def options_for_fifo
          options = {}
          options[:message_deduplication_id] =
            Digest::SHA256.hexdigest(Aws::Json.dump(deduplication_body))

          message_group_id = @job.message_group_id if @job.respond_to?(:message_group_id)
          message_group_id ||= Aws::Rails::SqsActiveJob.config.message_group_id

          options[:message_group_id] = message_group_id
          options
        end

        def deduplication_body
          ex_dedup_keys = @job.excluded_deduplication_keys if @job.respond_to?(:excluded_deduplication_keys)
          ex_dedup_keys ||= Aws::Rails::SqsActiveJob.config.excluded_deduplication_keys

          @body.except(*ex_dedup_keys)
        end
      end
    end
  end
end
