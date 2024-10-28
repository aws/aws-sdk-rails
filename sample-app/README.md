# aws-sdk-rails Sample App

This is a minimal app created with `rails new --minimal --skip-git sample-app`

An additional user scaffold was created with: `bundle exec rails generate scaffold user email:uniq password:digest`. Gem `bcrypt` was added to the Gemfile.

The database was migrated with: `bundle exec rails db:migrate`.

Our gems (`aws-sdk-rails` + feature gems) were added to the Gemfile.

## DynamoDB Session Store

### Setup

This is configured in `config/initializers/session_store.rb`. See [this guide](https://guides.rubyonrails.org/v3.1/configuring.html#rails-general-configuration) and the `aws-sdk-rails` README.

The default configuration file was generated with `bundle exec rails generate dynamo_db:session_store_config`.

The ActiveRecord session table migration was created with `bundle exec rails generate dynamo_db:session_store_migration`.

To create the table if it doesn't already exist, run `bundle exec rake dynamo_db:session_store:create_table`.

To override changes, change this app's Gemfile to use the local path.

### Testing

Start the service with `bundle exec rails server` and visit `http://127.0.0.1:3000/users`.

In the logs, you should see a notification for DynamoDB `update_item` with a `session_id`. This key should exist in your DynamoDB `sessions` table. Refreshing the page should update the session `updated_at` and/or `expired_at` and not create a new session.