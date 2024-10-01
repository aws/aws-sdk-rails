# frozen_string_literal: true

require_relative 'aws/rails/ses_mailer'
require_relative 'aws/rails/sesv2_mailer'
require_relative 'aws/rails/railtie'
require_relative 'aws/rails/action_mailbox/engine'
require_relative 'aws/rails/notifications'
# require_relative 'aws/rails/sqs_active_job'
# require_relative 'aws/rails/middleware/ebs_sqs_active_job_middleware'

require_relative 'action_dispatch/session/dynamodb_store'

require_relative 'generators/aws_record/base'

module Aws
  module Rails
    VERSION = File.read(File.expand_path('../VERSION', __dir__)).strip
  end
end
