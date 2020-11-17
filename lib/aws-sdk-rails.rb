# frozen_string_literal: true

require_relative 'aws/rails/mailer'
require_relative 'aws/rails/railtie'
require_relative 'aws/rails/notifications'
require_relative 'action_dispatch/session/dynamodb_store'
require_relative 'active_job/queue_adapters/aws_sqs_adapter'
require_relative 'aws/rails/sqs_job/configuration'
require_relative 'aws/rails/sqs_job/executor'
require_relative 'aws/rails/sqs_job/job_wrapper'



module Aws
  module Rails
    VERSION = File.read(File.expand_path('../VERSION', __dir__)).strip
  end
end