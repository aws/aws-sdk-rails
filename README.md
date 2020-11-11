# AWS SDK for Ruby Rails Plugin

[![Gem Version](https://badge.fury.io/rb/aws-sdk-rails.svg)](https://badge.fury.io/rb/aws-sdk-rails) [![Build Status](https://travis-ci.com/aws/aws-sdk-rails.svg?branch=master)](https://travis-ci.com/aws/aws-sdk-rails) [![Github forks](https://img.shields.io/github/forks/aws/aws-sdk-rails.svg)](https://github.com/aws/aws-sdk-rails/network)
[![Github stars](https://img.shields.io/github/stars/aws/aws-sdk-rails.svg)](https://github.com/aws/aws-sdk-rails/stargazers)
[![Gitter](https://badges.gitter.im/aws/aws-sdk-rails.svg)](https://gitter.im/aws/aws-sdk-rails?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)

A Ruby on Rails plugin that integrates AWS services with your application using
the latest version of [AWS SDK For Ruby](https://github.com/aws/aws-sdk-ruby).

## Installation

Add this gem to your Rails project's Gemfile:

```ruby
gem 'aws-sdk-rails'
```

This gem also brings in the `aws-sdk-core` and `aws-sdk-ses` gems. If you want
to use other services (such as S3), you will still need to add them to your
Gemfile:

```ruby
gem 'aws-sdk-rails', '~> 3'
gem 'aws-sdk-s3', '~> 1'
```

You will have to ensure that you provide credentials for the SDK to use. See the
latest [AWS SDK for Ruby Docs](https://docs.aws.amazon.com/sdk-for-ruby/v3/api/index.html#Configuration)
for details.

If you're running your Rails application on Amazon EC2, the AWS SDK will
check Amazon EC2 instance metadata for credentials to load. Learn more:
[IAM Roles for Amazon EC2](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/iam-roles-for-amazon-ec2.html)

# Features

## AWS SDK uses the Rails logger

The AWS SDK is configured to use the built-in Rails logger for any
SDK log output. The logger is configured to use the `:info` log level. You can
change the log level by setting `:log_level` in the
[Aws.config](https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws.html) hash.

```ruby
Aws.config.update(log_level: :debug)
```

## Rails 5.2+ Encrypted Credentials

If you are using Rails 5.2+ [Encrypted Credentials](http://guides.rubyonrails.org/security.html#custom-credentials),
the credentials will be decrypted and loaded under the `:aws` top level key:

```yml
# config/credentials.yml.enc
# viewable with: `rails credentials:edit`
aws:
  access_key_id: YOUR_KEY_ID
  secret_access_key: YOUR_ACCESS_KEY
```

## DynamoDB Session Store

You can configure session storage in Rails to use DynamoDB instead of cookies,
allowing access to sessions from other applications and devices. You will need
to have an existing Amazon DynamoDB session table to use this feature.

You can generate a migration file for the session table using the following
command (<MigrationName> is optional):

```bash
rails generate dynamo_db:session_store_migration <MigrationName>
```

The session store migration generator command will generate two	files: a
migration file, `db/migration/#{VERSION}_#{MIGRATION_NAME}.rb`, and a
configuration YAML file, `config/dynamo_db_session_store.yml`.

The migration file will create and delete a table with default options. These
options can be changed prior to running the migration and are documented in the
[Table](https://docs.aws.amazon.com/sdk-for-ruby/aws-sessionstore-dynamodb/api/Aws/SessionStore/DynamoDB/Table.html) class.

To create the table, run migrations as normal with:

```bash
rake db:migrate
```

Next, configure the Rails session store to be `:dynamodb_store` by editing
`config/initializers/session_store.rb` to contain the following:

```ruby
# config/initializers/session_store.rb
Rails.application.config.session_store :dynamodb_store, key: '_your_app_session'
```

You can now start your Rails application with session support.

### Configuration

You can configure the session store with code, YAML files, or ENV, in this order
of precedence. To configure in code, you can directly pass options to your
initializer like so:

```ruby
# config/initializers/session_store.rb
Rails.application.config.session_store :dynamodb_store,
  key: '_your_app_session',
  table_name: 'foo'
```

Alternatively, you can use the generated YAML configuration file
`config/dynamo_db_session_store.yml`. YAML configuration may also be specified
per environment, with environment configuration having precedence. To do this,
create `config/dynamo_db_session_store/#{Rails.env}.yml` files as needed.

For configuration options, see the [Configuration](https://docs.aws.amazon.com/sdk-for-ruby/aws-sessionstore-dynamodb/api/Aws/SessionStore/DynamoDB/Configuration.html) class.

#### Rack Configuration

DynamoDB session storage is implemented in the [`aws-sessionstore-dynamodb`](https://github.com/aws/aws-sessionstore-dynamodb-ruby)
gem. The Rack middleware inherits from the [`Rack::Session::Abstract::Persisted`](https://www.rubydoc.info/github/rack/rack/Rack/Session/Abstract/Persisted)
class, which also includes additional options (such as `:key`) that can be
passed into the Rails initializer.

### Cleaning old sessions

By default sessions do not expire. See `config/dynamo_db_session_store.yml` to
configure the max age or stale period of a session.

You can use the DynamoDB [Time to Live (TTL) feature](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/TTL.html)
on the `expire_at` attribute to automatically delete expired items.

Alternatively, a Rake task for garbage collection is provided:

```bash
rake dynamo_db:collect_garbage
```

## Amazon Simple Email Service (SES) as an ActionMailer Delivery Method

This gem will automatically register SES as an ActionMailer delivery method. You
simply need to configure Rails to use it in your environment configuration:

```ruby
# for e.g.: config/environments/production.rb
config.action_mailer.delivery_method = :ses
```

### Manually setting credentials

If you need to provide different credentials for Action Mailer, you can call
client-creating actions manually. For example, you can create an initializer
`config/initializers/aws.rb` with contents similar to the following:

```ruby
require 'json'

# Assuming a file "path/to/aws_secrets.json" with contents like:
#
#     { "AccessKeyId": "YOUR_KEY_ID", "SecretAccessKey": "YOUR_ACCESS_KEY" }
#
# Remember to exclude "path/to/aws_secrets.json" from version control, e.g. by
# adding it to .gitignore
secrets = JSON.load(File.read('path/to/aws_secrets.json'))
creds = Aws::Credentials.new(secrets['AccessKeyId'], secrets['SecretAccessKey'])

Aws::Rails.add_action_mailer_delivery_method(
  :ses,
  credentials: creds,
  region: 'us-east-1'
)
```

### Using ARNs with SES

This gem uses [`Aws::SES::Client#send_raw_email`](https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/SES/Client.html#send_raw_email-instance_method)
to send emails. This operation allows you to specify a cross-account identity
for the email's Source, From, and Return-Path. To set these ARNs, use any of the
following headers on your `Mail::Message` object returned by your Mailer class:

* X-SES-SOURCE-ARN

* X-SES-FROM-ARN

* X-SES-RETURN-PATH-ARN

Example:

```
# in your Rails controller
message = MyMailer.send_email(options)
message['X-SES-FROM-ARN'] = 'arn:aws:ses:us-west-2:012345678910:identity/bigchungus@memes.com'
message.deliver
```

## Active Support Notification Instrumentation for AWS SDK calls
To add `ActiveSupport::Notifications` Instrumentation to all AWS SDK client
operations call `Aws::Rails.instrument_sdk_operations` before you construct any
SDK clients.

Example usage in `config/initializers/instrument_aws_sdk.rb`
```ruby
Aws::Rails.instrument_sdk_operations
```

Events are published for each client operation call with the following event
name: <operation>.<serviceId>.aws.  For example, S3's put_object has an event
name of: `put_object.S3.aws`.  The payload of the event is the
[request context](https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Seahorse/Client/RequestContext.html).

You can subscribe to these events as you would other
 `ActiveSupport::Notifications`:

 ```ruby
ActiveSupport::Notifications.subscribe('put_object.s3.aws') do |name, start, finish, id, payload|
  # process event
end

# Or use a regex to subscribe to all service notifications
ActiveSupport::Notifications.subscribe(/s3[.]aws/) do |name, start, finish, id, payload|
  # process event
end
```
