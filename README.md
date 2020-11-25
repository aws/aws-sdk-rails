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

Encrypted Credentials will take precedence over any other AWS Credentials that
may exist in your environment (eg: credentials from profiles set in
 `~/.aws/credentials`).

If you are using [ActiveStorage](https://edgeguides.rubyonrails.org/active_storage_overview.html)
with `S3` then you do not need to specify your credentials in your `storage.yml`
configuration: they will be loaded automatically.

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
## AWS Record Generators

This package also pulls in the [`aws-record` gem](https://github.com/aws/aws-sdk-ruby-record)
and provides generators for creating models and a rake task for performing
table config migrations.

### Setup

You can either invoke the generator by calling `rails g aws_record:model ...`

If DynamoDB will be the only datastore you plan on using you can also set `aws-record-generator` to be your project's default orm with

```ruby
config.generators do |g|
  g.orm :aws_record
end
```
Which will cause `aws_record:model` to be invoked by the Rails model generator.


### Generating a model

Generating a model can be as simple as: `rails g aws_record:model Forum --table-config primary:10-5`
`aws-record-generator` will automatically create a `uuid:hash_key` field for you, and a table config with the provided r/w units

```ruby
# app/models/forum.rb

require 'aws-record'

class Forum
  include Aws::Record

  string_attr :uuid, hash_key: true
end

# db/table_config/forum_config.rb

require 'aws-record'

module ModelTableConfig
  def self.config
    Aws::Record::TableConfig.define do |t|
      t.model_class Forum

      t.read_capacity_units 10
      t.write_capacity_units 5
    end
  end
end
```

More complex models can be created by adding more fields to the model as well as other options:

`rails g aws_record Forum post_id:rkey author_username post_title post_body tags:sset:default_value{Set.new}`

```ruby
# app/models/forum.rb

require 'aws-record'

class Forum
  include Aws::Record

  string_attr :uuid, hash_key: true
  string_attr :post_id, range_key: true
  string_attr :author_username
  string_attr :post_title
  string_attr :post_body
  string_set_attr :tags, default_value: Set.new
end

# db/table_config/forum_config.rb
# ...
```

Finally you can attach a variety of options to your fields, and even `ActiveModel` validations to the models:

`rails g aws_record:model Forum forum_uuid:hkey post_id:rkey author_username post_title post_body tags:sset:default_value{Set.new} created_at:datetime:db_attr_name{PostCreatedAtTime} moderation:boolean:default_value{false} --table-config=primary:5-2 AuthorIndex:12-14 --required=post_title --length-validations=post_body:50-1000 --gsi=AuthorIndex:hkey{author_username}`

Which results in the following files being generated:

```ruby
# app/models/forum.rb

require 'aws-record'
require 'active_model'

class Forum
  include Aws::Record
  include ActiveModel::Validations

  string_attr :forum_uuid, hash_key: true
  string_attr :post_id, range_key: true
  string_attr :author_username
  string_attr :post_title
  string_attr :post_body
  string_set_attr :tags, default_value: Set.new
  datetime_attr :created_at, database_attribute_name: "PostCreatedAtTime"
  boolean_attr :moderation, default_value: false

  global_secondary_index(
    :AuthorIndex,
    hash_key: :author_username,
    projection: {
      projection_type: "ALL"
    }
  )
  validates_presence_of :post_title
  validates_length_of :post_body, within: 50..1000
end

# db/table_config/forum_config.rb
# ...
```

To migrate your new models and begin using them you can run the provided rake task: `rails aws_record:migrate`

### Docs

The syntax for creating an aws-record model follows:

`rails generate aws_record:model NAME [field[:type][:opts]...] [options]`

The possible field types are:

Field Name | aws-record attribute type
---------------- | -------------
`bool \| boolean` | :boolean_attr
`date` | :date_attr
`datetime` | :datetime_attr
`float` | :float_attr
`int \| integer` | :integer_attr
`list` | :list_attr
`map` | :map_attr
`num_set \| numeric_set \| nset` | :numeric_set_attr
`string_set \| s_set \| sset` | :string_set_attr
`string` | :string_attr


If a type is not provided, it will assume the field is of type `:string_attr`.

Additionally a number of options may be attached as a comma separated list to the field:

Field Option Name | aws-record option
---------------- | -------------
`hkey` | marks an attribute as a hash_key
`rkey` | marks an attribute as a range_key
`persist_nil` | will persist nil values in a attribute
`db_attr_name{NAME}` | sets a secondary name for an attribute, these must be unique across attribute names
`ddb_type{S\|N\|B\|BOOL\|SS\|NS\|BS\|M\|L}` | sets the dynamo_db_type for an attribute
`default_value{Object}` | sets the default value for an attribute

The standard rules apply for using options in a model. Additional reading can be found [here](#links-of-interest)

Command Option Names | Purpose
-------------------- | -----------
  [--skip-namespace], [--no-skip-namespace]                                             | Skip namespace (affects only isolated applications)
  [--disable-mutation-tracking], [--no-disable-mutation-tracking]                       | Disables dirty tracking
  [--timestamps], [--no-timestamps]                                                     | Adds created, updated timestamps to the model
  --table-config=primary:R-W [SecondaryIndex1:R-W]...                                   | Declares the r/w units for the model as well as any secondary indexes
  [--gsi=name:hkey{field_name}[,rkey{field_name},proj_type{ALL\|KEYS_ONLY\|INCLUDE}]...]  | Allows for the declaration of secondary indexes
  [--required=field1...]                                                                | A list of attributes that are required for an instance of the model
  [--length-validations=field1:MIN-MAX...]                                              | Validations on the length of attributes in a model
  [--table-name=name] | Sets the name of the table in DynamoDB, if different than the model name
  [--skip-table-config] | Doesn't generate a table config for the model
  [--password-digest] | Adds a password field (note that you must have bcrypt has a dependency) that automatically hashes and manages the model password
  [--scaffold] | Adds helpers methods that are used by the scaffolding

The included rake task `aws_record:migrate` will run all of the migrations in `app/db/table_config`
