require 'test_helper'

module ActionDispatch
  module Session
    class DynamodbStoreTest < ActiveSupport::TestCase
      def setup
        # normally this would be a rack app, but we only want to test that
        # options are loaded on initialize
        @app = nil
      end

      def test_loads_config_file
        store = ActionDispatch::Session::DynamodbStore.new(@app, {})
        config = store.instance_variable_get(:@config)
        config_file_path = config.instance_variable_get(:@config_file).to_s
        assert_match /dynamo_db_session_store.yml/, config_file_path
      end

      def test_loads_environment_config_file_and_with_precedence
        # Set Rails.env to something else so the environment.yml file is loaded
        old_env = Rails.env
        Rails.env = 'environment'

        store = ActionDispatch::Session::DynamodbStore.new(@app, {})
        config = store.instance_variable_get(:@config)
        config_file_path = config.instance_variable_get(:@config_file).to_s
        assert_match /environment.yml/, config_file_path

        # Reload old env
        Rails.env = old_env
      end

      def test_allows_config_file_override
        options = { config_file: 'test/dummy/config/session_store.yml' }
        store = ActionDispatch::Session::DynamodbStore.new(@app, options)
        config = store.instance_variable_get(:@config)
        config_file_path = config.instance_variable_get(:@config_file).to_s
        assert_match /session_store.yml/, config_file_path
      end

      def test_uses_rails_secret_key_base
        store = ActionDispatch::Session::DynamodbStore.new(@app, {})
        config = store.instance_variable_get(:@config)
        assert_equal config.secret_key, Rails.application.secret_key_base
      end

      def test_allows_secret_key_override
        secret_key = 'SECRET_KEY'
        options = { secret_key: secret_key }
        store = ActionDispatch::Session::DynamodbStore.new(@app, options)
        config = store.instance_variable_get(:@config)
        assert_equal config.secret_key, secret_key
      end
    end
  end
end
