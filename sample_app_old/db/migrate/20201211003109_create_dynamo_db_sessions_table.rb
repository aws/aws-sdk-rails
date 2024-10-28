class CreateDynamoDbSessionsTable < ActiveRecord::Migration[6.1]
  def up
    Aws::SessionStore::DynamoDB::Table.create_table
  end

  def down
    Aws::SessionStore::DynamoDB::Table.delete_table
  end
end
