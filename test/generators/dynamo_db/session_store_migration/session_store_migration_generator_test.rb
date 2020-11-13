require 'test_helper'

require 'rails/generators/test_case'
require 'generators/dynamo_db/session_store_migration/session_store_migration_generator'

module DynamoDb
  module Generators
    class SessionStoreMigrationGeneratorTest < Rails::Generators::TestCase
      tests SessionStoreMigrationGenerator
      destination File.expand_path('../../../dummy', __dir__)

      def test_migration_with_default_name
        run_generator ['-f']
        assert_migration 'db/migrate/create_dynamo_db_sessions_table.rb'
      end

      def test_migration_with_custom_name
        run_generator ['CustomName', '-f']
        assert_migration 'db/migrate/custom_name.rb'
      end

      def test_migration_includes_config_file
        run_generator ['-f']
        assert_file 'config/dynamo_db_session_store.yml'
      end
    end
  end
end
