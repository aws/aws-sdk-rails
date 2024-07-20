# frozen_string_literal: true

require_relative '../../active_job/queue_adapters/sqs_adapter'
require_relative '../../active_job/queue_adapters/sqs_adapter/params'
require_relative '../../active_job/queue_adapters/sqs_async_adapter'
require_relative 'sqs_active_job/configuration'
require_relative 'sqs_active_job/deduplication'
require_relative 'sqs_active_job/executor'
require_relative 'sqs_active_job/job_runner'
require_relative 'sqs_active_job/lambda_handler'

module Aws
  module Rails
    # == AWS SQS ActiveJob.
    #
    # SQS-based queuing backend for Active Job.
    module SqsActiveJob; end
  end
end
