# frozen_string_literal: true

require 'test_helper'

require 'aws-sdk-dynamodb'

module ActionDispatch
  module Session
    class DynamoDbStoreTest < ActiveSupport::TestCase
      let(:options) do
        { dynamo_db_client: Aws::DynamoDB::Client.new(stub_responses: true) }
      end

      def setup_env
        ENV['DYNAMO_DB_SESSION_CONFIG_FILE'] = 'test/dummy/config/session_store.yml'
      end

      def teardown_env
        ENV.delete('DYNAMO_DB_SESSION_CONFIG_FILE')
      end

      it 'loads config file' do
        store = ActionDispatch::Session::DynamoDbStore.new(nil, options)
        config_file_path = store.config.config_file.to_s
        assert_match(/dynamo_db_session_store.yml/, config_file_path)
      end

      it 'loads environment specific config files with precedence' do
        # Set Rails.env to something else so the environment.yml file is loaded
        old_env = Rails.env
        Rails.env = 'development'

        store = ActionDispatch::Session::DynamoDbStore.new(nil, options)
        config_file_path = store.config.config_file.to_s
        assert_match(/development.yml/, config_file_path)

        # Reload old env
        Rails.env = old_env
      end

      it 'loads a config file from the environment variable with precedence' do
        setup_env
        store = ActionDispatch::Session::DynamoDbStore.new(nil, options)
        config_file_path = store.config.config_file.to_s
        assert_match(/session_store.yml/, config_file_path)
        teardown_env
      end

      it 'allows overriding the config file at runtime with highest precedence' do
        setup_env
        options[:config_file] = 'test/dummy/config/session_store.yml'
        store = ActionDispatch::Session::DynamoDbStore.new(nil, options)
        config_file_path = store.config.config_file.to_s
        assert_match(/session_store.yml/, config_file_path)
        teardown_env
      end

      it 'uses the rails secret key base' do
        store = ActionDispatch::Session::DynamoDbStore.new(nil, options)
        assert_equal store.config.secret_key, Rails.application.secret_key_base
      end

      it 'allows for secret key to be overridden' do
        secret_key = 'SECRET_KEY'
        options[:secret_key] = secret_key
        store = ActionDispatch::Session::DynamoDbStore.new(nil, options)
        assert_equal store.config.secret_key, secret_key
      end
    end
  end
end
