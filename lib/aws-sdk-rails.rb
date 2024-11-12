# frozen_string_literal: true

require_relative 'aws/rails/ses_mailer'
require_relative 'aws/rails/sesv2_mailer'
require_relative 'aws/rails/railtie'
require_relative 'aws/rails/action_mailbox/engine'
require_relative 'aws/rails/notifications'

# remove this in aws-sdk-rails 5
require 'aws-sessionstore-dynamodb'
require 'aws-activejob-sqs'

require_relative 'action_dispatch/session/dynamo_db_store' if defined?(Aws::SessionStore::DynamoDB::RackMiddleware)

module Aws
  module Rails
    VERSION = File.read(File.expand_path('../VERSION', __dir__)).strip
  end
end
