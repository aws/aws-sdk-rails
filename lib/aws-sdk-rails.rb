# frozen_string_literal: true

require_relative 'aws/rails/mailer'
require_relative 'aws/rails/railtie'
require_relative 'aws/rails/notifications'

require_relative 'action_dispatch/session/dynamodb_store'

require_relative 'generators/aws_record/base'
require_relative 'generators/aws_record/generated_attribute'
require_relative 'generators/aws_record/secondary_index'
