# frozen_string_literal: true

require 'rails/generators/named_base'

module DynamoDb
  module Generators
    # Generates an ActiveRecord migration that creates and deletes a DynamoDB
    # Session table.
    class SessionStoreMigrationGenerator < Rails::Generators::NamedBase
      include Rails::Generators::Migration

      source_root File.expand_path('templates', __dir__)

      # Desired name of the migration class
      argument :name,
        desc: 'Optional name of the migration class',
        type: :string,
        default: 'create_dynamo_db_sessions_table'

      def generate_migration_file
        migration_template(
          'session_store_migration.erb',
          "db/migrate/#{name.underscore}.rb"
        )
      end

      # Next migration number - must be implemented
      def self.next_migration_number(_dir = nil)
        Time.now.utc.strftime('%Y%m%d%H%M%S')
      end

      private

      def migration_version
        "#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}"
      end
    end
  end
end
