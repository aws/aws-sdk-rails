# frozen_string_literal: true

require 'test_helper'

require 'rake'

module DynamoDb
  class SessionStoreRakeTest < ActiveSupport::TestCase
    before do
      Rake.application.rake_require 'tasks/dynamo_db/session_store'
      Rake::Task.define_task(:environment)
    end

    # Functionality for these methods are tested in aws-sessionstore-dynamodb.
    # For these tests, just validate the task can be invoked and calls the
    # appropriate methods.
    def expect_mock(method, task)
      klass =
        if method == :collect_garbage
          Aws::SessionStore::DynamoDB::GarbageCollection
        else
          Aws::SessionStore::DynamoDB::Table
        end

      mock = MiniTest::Mock.new
      mock.expect(:call, nil)
      klass.stub(method, mock) { Rake.application.invoke_task task }
      assert_mock mock
    end

    it 'has a creates table task' do
      expect_mock(:create_table, 'dynamo_db:session_store:create_table')
    end

    it 'has a deletes table task' do
      expect_mock(:delete_table, 'dynamo_db:session_store:delete_table')
    end

    it 'has a cleans table task' do
      expect_mock(:collect_garbage, 'dynamo_db:session_store:clean_table')
    end
  end
end
