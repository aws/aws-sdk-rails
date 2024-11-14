# aws-sdk-rails Sample App

This is a minimal app created with `rails new --minimal --skip-git sample-app`

An additional user scaffold was created with: `bundle exec rails generate scaffold user email:uniq password:digest`. Gem `bcrypt` was added to the Gemfile.

The database was migrated with: `bundle exec rails db:migrate`.

Our gems (`aws-sdk-rails` + feature gems) were added to the Gemfile.

Gem `byebug` is added to help with development.

## AWS Rails Logger

### Setup

The Railtie is already configured to setup the Rails logger as the global `Aws.config[:logger]`.

### Testing

Run `bundle exec rails console` to start the console.

Inspect the output of `Aws.config[:logger]` and ensure it is an `ActiveSupport` logger.

## Encrypted Credentials

### Setup

Run `EDITOR=nano bundle exec rails credentials:edit` to edit credentials.

Commented credentials are defined under the `:aws` key. Uncomment the credentials, which should look like:

```yaml
aws:
  access_key_id: secret
  secret_access_key: akid
  session_token: token
  account_id: account
```

### Testing

Run `bundle exec rails console` to start the console.

Inspect the output of `Aws.config` and ensure the credentials are set.

## ActiveSupport Notifications

### Setup

This is configured in `config/initializers/instrument_aws_sdk.rb`. See the `aws-sdk-rails` README.

`UsersController#index` captures any AWS SDK notification with:

```ruby
ActiveSupport::Notifications.subscribe(/[.]aws/) do |name, start, finish, id, _payload|
  Rails.logger.info "Got notification: #{name} #{start} #{finish} #{id}"
end
```

### Testing

Start the service with `bundle exec rails server` and visit `http://127.0.0.1:3000/users`.

In the logs, you should at least see a notification for DynamoDB `update_item` from the session store.
It should look like:

```
Got notification: update_item.DynamoDB.aws ...
```

## DynamoDB SessionStore

### Setup

This is configured in `config/initializers/session_store.rb`. See [this guide](https://guides.rubyonrails.org/v3.1/configuring.html#rails-general-configuration) and the `aws-sdk-rails` README.

The default configuration file was generated with `bundle exec rails generate dynamo_db:session_store_config`.

The ActiveRecord session table migration was created with `bundle exec rails generate dynamo_db:session_store_migration`.

To create the table if it doesn't already exist, run `bundle exec rake dynamo_db:session_store:create_table`.

To override changes, change this app's Gemfile to use the local path.

### Testing

Start the service with `bundle exec rails server` and visit `http://127.0.0.1:3000/users`.

In the logs, you should see a notification for DynamoDB `update_item` with a `session_id`. This key should exist in your DynamoDB `sessions` table. Refreshing the page should update the session `updated_at` and/or `expired_at` and not create a new session.

## SQS ActiveJob

### Setup

The jobs were generated with `bundle exec rails generate job Test` and `bundle exec rails generate job TestAsync`.

An empty controller scaffold was generated with `bundle exec rails generate controller Job`.

`TestJob` and `TestAsyncJob` was implemented to print the job's args.

`JobController` and routes were added to queue the job.

`config/application.rb` added `require "active_job/railtie"`.

> **Important**: Create an SQS queue and retrieve the queue URL.

### Testing

Start rails with `AWS_ACTIVE_JOB_QUEUE_URL=https://my_sqs_queue_url bundle exec rails server`

Poll for and process jobs with: `AWS_ACTIVE_JOB_QUEUE_URL=https://my_sqs_queue_url bundle exec aws_sqs_active_job --queue default`

Visit `http://127.0.0.1:3000/queue_sqs_job` and `http://127.0.0.1:3000/queue_sqs_async_job` to queue jobs. The output of both jobs should be printed in the logs.

### Testing with ElasticBeanstalk workers
Create a EB application with a worker environment (rather than web server environment) using the Ruby platform.  Use the default settings (including using the default/sample app initially) except:
1. Set `AWS_PROCESS_BEANSTALK_WORKER_REQUESTS` to `true` in the environment configuration.
2. Set the worker queue to your queue.  IF you don't configure this explicitly, a new queue will be created instead.
3. [optional] Configure a larger instance type (eg x3.large).

After initial deployment of the sample app, create a zip of the sample-app: `zip ../sample-app.zip -r * .[^.]*`.  Create a new version and deploy it.

Run the sample-app locally and submit jobs:
1. `rails c`
2. `TestJob.perform_later(hello: 'from ebs')` 

You can then request the logs and should see processing of the job in `/var/log/puma/puma.log`

## Deploying / Testing on ElasticBeanstalk Web Server
Create a EB application with a web server environment using the Ruby platform.  Use the default settings (including using the default/sample app initially) except:
1. Set `SECRET_KEY_BASE` to some arbitrary alphanumeric string in the environment configuration.
2. [optional] Configure a larger instance type (eg x3.large).

Edit the sample app and ensure that ssl redirects are disabled.  In `config/environments/production.rb`:

```ruby
  config.assume_ssl = false
  config.force_ssl = false
  config.ssl_options = { redirect: false, secure_cookies: false, hsts: false }
```

And add an nginix config file at `sample-app/.platform/nginx/conf.d/10-types-hash.conf`:

```
types_hash_max_size 4096;
```

After initial deployment of the sample app, create a zip of the sample-app: `zip ../sample-app.zip -r * .[^.]*`.  Create a new version and deploy it.

You can find web logs under `/var/log/puma/puma.log`
