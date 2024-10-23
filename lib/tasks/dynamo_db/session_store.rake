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
    task collect_garbage: :environment do
      Aws::SessionStore::DynamoDB::GarbageCollection.collect_garbage
    end
  end
end
