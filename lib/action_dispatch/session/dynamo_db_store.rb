# frozen_string_literal: true

require 'action_dispatch/middleware/session/abstract_store'

module ActionDispatch
  module Session
    # Uses the Dynamo DB Session Store implementation to create a class that
    # extends `ActionDispatch::Session`. Rails will create a `:dynamo_db_store`
    # configuration for `:session_store` from this class name.
    #
    # This class will use `Rails.application.secret_key_base` as the secret key
    # unless otherwise provided.
    #
    # Configuration can also be provided in YAML files from Rails config, either
    # in "config/dynamo_db_session_store.yml" or "config/dynamo_db_session_store/#\\{Rails.env}.yml".
    # Configuration files that are environment-specific will take precedence.
    #
    # @see https://docs.aws.amazon.com/sdk-for-ruby/aws-sessionstore-dynamodb/api/Aws/SessionStore/DynamoDB/Configuration.html
    class DynamoDbStore < Aws::SessionStore::DynamoDB::RackMiddleware
      include StaleSessionCheck
      include SessionObject

      def initialize(app, options = {})
        options[:config_file] ||= config_file
        options[:secret_key] ||= Rails.application.secret_key_base
        super
      end

      private

      def config_file
        file = Rails.root.join("config/dynamo_db_session_store/#{Rails.env}.yml")
        file = Rails.root.join('config/dynamo_db_session_store.yml') unless File.exist?(file)
        file if File.exist?(file)
      end
    end

    # @api private
    class DynamodbStore < DynamoDbStore
      def initialize(app, options = {})
        Rails.logger.warn('Session Store :dynamodb_store has been renamed to :dynamo_db_store, ' \
                          'please use the new key instead. :dynamodb_store will be removed in ' \
                          'aws-sdk-rails ~> 5')
        super
      end
    end
  end
end
