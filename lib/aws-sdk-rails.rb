# frozen_string_literal: true

require_relative 'aws/rails/middleware/elastic_beanstalk_sqsd'
require_relative 'aws/rails/railtie'
require_relative 'aws/rails/notifications'

# remove these in aws-sdk-rails 5
require 'aws-actiondispatch-dynamodb'
require 'aws-actionmailbox-ses' if defined?(ActionMailbox::Engine)
require 'aws-actionmailer-ses'
require 'aws-activejob-sqs'
require 'aws-record-rails'

module Aws
  module Rails
    VERSION = File.read(File.expand_path('../VERSION', __dir__)).strip
  end
end

# remove these in aws-sdk-rails 5
Aws::Rails::SqsActiveJob = Aws::ActiveJob::SQS
Aws::Rails::EbsSqsActiveJobMiddleware = Aws::Rails::Middleware::ElasticBeanstalkSQSD
Aws::Rails::SesMailer = Aws::ActionMailer::SES::Mailer
Aws::Rails::Sesv2Mailer = Aws::ActionMailer::SESV2::Mailer
# This is for backwards compatibility after introducing support for SESv2.
# The old mailer is now replaced with the new SES (v1) mailer.
Aws::Rails::Mailer = Aws::Rails::SesMailer
