require 'rails/generators/named_base'

# This class generates a migration file for deleting and creating
# a DynamoDB sessions table.
module DynamoDb
  module Generators
    # Generates an ActiveRecord migration that creates and deletes a DynamoDB
    # Session table.
    class SessionStoreMigrationGenerator < Rails::Generators::NamedBase
      include Rails::Generators::Migration

      source_root File.expand_path('templates', __dir__)

      # Desired name of migration class
      argument :name, type: :string, default: 'sessionstore_migration'

      # @return [Rails Migration File] migration file for creation and deletion
      #   of a DynamoDB session table.
      def generate_migration_file
        migration_template(
          'session_store_migration.rb',
          "#{Rails.root}/db/migrate/#{file_name}.rb"
        )
      end

      def copy_sample_config_file
        template(
          'dynamo_db_session_store.yml',
          "#{Rails.root}/config/dynamo_db_session_store.yml"
        )
      end

      # Inherited, must be implemented
      def self.next_migration_number(dirname)
        next_migration_number = current_migration_number(dirname) + 1
        ActiveRecord::Migration.next_migration_number(next_migration_number)
      end

      private

      # @return [String] filename
      def file_name
        name.underscore
      end

      # @return [String] activerecord migration version
      def migration_version
        "#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}"
      end
    end
  end
end
