require 'test_helper'

require 'rake'

module DynamoDb
  class SessionStoreRakeTest < ActiveSupport::TestCase
    def setup
      Rake.application.rake_require 'tasks/dynamo_db/session_store'
      Rake::Task.define_task(:environment)
    end

    # Functionality is tested in aws-sessionstore-dynamodb.
    # So for this test, just valdiate that the task can be invoked
    # and it calls the collect_garbage method on the GarbageCollector.
    def test_clean_task
      mock = MiniTest::Mock.new
      mock.expect(:call, nil)

      Aws::SessionStore::DynamoDB::GarbageCollection.stub(:collect_garbage, mock) do
        Rake.application.invoke_task 'dynamo_db:session_store:clean'
      end

      mock.verify
    end
  end
end
