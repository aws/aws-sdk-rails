require 'minitest/autorun'

require 'active_support/test_case'
require 'active_record'

module DynamoDb
  module SessionStore
    class CleanRakeTest < ActiveSupport::TestCase
      class CreateDynamoDbSessionsTable < ActiveRecord::Migration[6.0]
        def up
          Aws::SessionStore::DynamoDB::Table.create_table
        end

        def down
          Aws::SessionStore::DynamoDB::Table.delete_table
        end
      end

      def test
        puts "test?"
      end

    end
  end
end
