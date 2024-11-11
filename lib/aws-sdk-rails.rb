# frozen_string_literal: true

require_relative 'aws/rails/railtie'
require_relative 'aws/rails/action_mailbox/engine'
require_relative 'aws/rails/notifications'
require_relative 'aws/rails/sqs_active_job'
require_relative 'aws/rails/middleware/ebs_sqs_active_job_middleware'

# remove this in aws-sdk-rails 5
require 'aws-sessionstore-dynamodb'
require 'aws-actionmailer-ses'

require_relative 'action_dispatch/session/dynamo_db_store' if defined?(Aws::SessionStore::DynamoDB::RackMiddleware)

module Aws
  module Rails
    VERSION = File.read(File.expand_path('../VERSION', __dir__)).strip
  end
end

# Remove these in aws-sdk-rails ~> 5
Aws::Rails::SesMailer = Aws::ActionMailer::SESMailer
Aws::Rails::Sesv2Mailer = Aws::ActionMailer::SESV2Mailer
# This is for backwards compatibility after introducing support for SESv2.
# The old mailer is now replaced with the new SES (v1) mailer.
Aws::Rails::Mailer = Aws::Rails::SesMailer
