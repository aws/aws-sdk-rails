require 'minitest/autorun'

require 'rails/generators/test_case'
require_relative '../../../../lib/generators/dynamo_db/session_store_migration/session_store_migration_generator'

module DynamoDb
  module Generators
    class SessionStoreMigrationGeneratorTest < Rails::Generators::TestCase
      tests SessionStoreMigrationGenerator
      destination File.expand_path("../../../tmp", __dir__)
      setup :prepare_destination

      test 'generates the migration file' do
        run_generator
        assert_migration 'db/migrate/create_dynamo_db_sessions_table.rb'
      end

      test 'generates the config file' do
        run_generator
        assert_file 'config/dynamo_db_session_store.yml'
      end
    end
  end
end
