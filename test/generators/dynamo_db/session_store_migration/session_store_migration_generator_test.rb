# frozen_string_literal: true

require 'test_helper'

require 'fileutils'
require 'rails/generators/test_case'
require 'generators/dynamo_db/session_store_migration/session_store_migration_generator'

module DynamoDb
  module Generators
    class SessionStoreMigrationGeneratorTest < Rails::Generators::TestCase
      tests SessionStoreMigrationGenerator
      destination File.expand_path('../../../dummy', __dir__)

      def test_migration_with_default_name
        FileUtils.rm_rf(Dir["#{destination_root}/db/migrate/*create_dynamo_db_sessions_table.rb"])
        run_generator
        assert_migration 'db/migrate/create_dynamo_db_sessions_table.rb'
      end

      def test_migration_with_custom_name
        FileUtils.rm_rf( Dir["#{destination_root}/db/migrate/*custom_name.rb"])
        run_generator %w[CustomName]
        assert_migration 'db/migrate/custom_name.rb'
      end
    end
  end
end
