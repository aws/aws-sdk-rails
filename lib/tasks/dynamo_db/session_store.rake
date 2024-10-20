# frozen_string_literal: true

namespace 'dynamo_db' do
  namespace 'session_store' do
    desc 'Create the Amazon DynamoDB session store table'
    task create_table: :environment do
      Aws::SessionStore::DynamoDB::Table.create_table
    end

    desc 'Delete the Amazon DynamoDB session store table'
    task delete_table: :environment do
      Aws::SessionStore::DynamoDB::Table.delete_table
    end

    desc 'Clean up old sessions in the Amazon DynamoDB session store table'
    task clean_table: :environment do
      Aws::SessionStore::DynamoDB::GarbageCollection.collect_garbage
    end

    task clean: :clean_table do
      puts 'The `dynamo_db:session_store:clean` task will be removed in aws-sdk-rails ~> 5. ' \
           'Please use `dynamo_db:session_store:clean_table` instead.'
    end
  end
end
