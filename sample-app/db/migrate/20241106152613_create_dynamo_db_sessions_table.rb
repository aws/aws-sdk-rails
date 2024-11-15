# frozen_string_literal: true

class CreateDynamoDbSessionsTable < ActiveRecord::Migration[7.2]
  def up
    options = Rails.application.config.session_options
    Aws::SessionStore::DynamoDB::Table.create_table(options)
  end

  def down
    options = Rails.application.config.session_options
    Aws::SessionStore::DynamoDB::Table.delete_table(options)
  end
end
