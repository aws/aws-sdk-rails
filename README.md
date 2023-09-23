# AWS SDK for Ruby Rails Plugin

[![Gem Version](https://badge.fury.io/rb/aws-sdk-rails.svg)](https://badge.fury.io/rb/aws-sdk-rails)
[![Build Status](https://github.com/aws/aws-sdk-rails/workflows/CI/badge.svg)](https://github.com/aws/aws-sdk-rails/actions)
 [![Github forks](https://img.shields.io/github/forks/aws/aws-sdk-rails.svg)](https://github.com/aws/aws-sdk-rails/network)
[![Github stars](https://img.shields.io/github/stars/aws/aws-sdk-rails.svg)](https://github.com/aws/aws-sdk-rails/stargazers)

A Ruby on Rails plugin that integrates AWS services with your application using
the latest version of [AWS SDK For Ruby](https://github.com/aws/aws-sdk-ruby).

## Installation

Add this gem to your Rails project's Gemfile:

```ruby
gem 'aws-sdk-rails'
```

This gem also brings in the following AWS gems:

* `aws-sdk-ses`
* `aws-sdk-sesv2`
* `aws-sdk-sqs`
* `aws-record`
* `aws-sessionstore-dynamodb`

If you want to use other services (such as S3), you will still need to add them to your
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
rails db:migrate
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
  table_name: 'foo',
  dynamo_db_client: my_ddb_client
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

This gem will automatically register SES and SESV2 as ActionMailer delivery methods.
You simply need to configure Rails to use it in your environment configuration:

```ruby
# for e.g.: config/environments/production.rb
config.action_mailer.delivery_method = :ses # or :sesv2
```

### Override credentials or other client options

Client options can be overridden by re-registering the mailer with any set of
SES or SESV2 Client options. You can create a Rails initializer
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
  :ses, # or :sesv2
  credentials: creds,
  region: 'us-east-1',
  # some other config
)
```

### Using ARNs with SES

This gem uses [`Aws::SES::Client#send_raw_email`](https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/SES/Client.html#send_raw_email-instance_method)
and [`Aws::SESV2::Client#send_email`](https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/SESV2/Client.html#send_email-instance_method)
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
name of: `put_object.S3.aws`.  The service name will always match the
namespace of the service client (eg Aws::S3::Client => 'S3').
The payload of the event is the
[request context](https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Seahorse/Client/RequestContext.html).

You can subscribe to these events as you would other
 `ActiveSupport::Notifications`:

 ```ruby
ActiveSupport::Notifications.subscribe('put_object.S3.aws') do |name, start, finish, id, payload|
  # process event
end

# Or use a regex to subscribe to all service notifications
ActiveSupport::Notifications.subscribe(/S3[.]aws/) do |name, start, finish, id, payload|
  # process event
end
```

## AWS SQS Active Job
This package provides a lightweight, high performance SQS backend
for [ActiveJob](https://guides.rubyonrails.org/active_job_basics.html).  

To use AWS SQS ActiveJob as your queuing backend, simply set the `active_job.queue_adapter`
to `:amazon` or `:amazon_sqs` (note, `:amazon` has been used for a number of
 other Amazon rails adapters such as ActiveStorage, so has been
 carried forward as convention here).  For details on setting the
 queuing backend see:
[ActiveJob: Setting the Backend](https://guides.rubyonrails.org/active_job_basics.html#setting-the-backend).
To use the non-blocking (async) adapter set `active_job.queue_adapter` to `:amazon_sqs_async`.  If you have
a lot of jobs to queue or you need to avoid the extra latency from an SQS call in your request then consider
using the async adapter.  However, you may also want to configure a `async_queue_error_handler` to
handle errors that may occur when queuing jobs.  See the
[Aws::Rails::SqsActiveJob::Configuration](https://docs.aws.amazon.com/sdk-for-ruby/aws-sdk-rails/api/Aws/Rails/SqsActiveJob/Configuration.html)
for documentation.


```ruby
# config/application.rb
module YourApp
  class Application < Rails::Application
    config.active_job.queue_adapter = :amazon_sqs # note: can use either :amazon or :amazon_sqs
    # To use the non-blocking async adapter:
    # config.active_job.queue_adapter = :amazon_sqs_async
  end
end

# Or to set the adapter for a single job:
class YourJob < ApplicationJob
  self.queue_adapter = :amazon_sqs
  #....
end
```

You also need to configure a mapping of ActiveJob queue name to SQS Queue URL. For more details, see the configuration section below.

```ruby
# config/aws_sqs_active_job.yml
queues:
  default: 'https://my-queue-url.amazon.aws'
```

To queue a job, you can just use standard ActiveJob methods:
```ruby
# To queue for immediate processing
YourJob.perform_later(args)

# or to schedule a job for a future time:
YourJob.set(wait: 1.minute).perform_later(args)
```

Note: Due to limitations in SQS, you cannot schedule jobs for
later than 15 minutes in the future.

### Performance
AWS SQS ActiveJob is a lightweight and performant queueing backend.  Benchmark performed using: Ruby MRI 2.6.5,  
shoryuken 5.0.5, aws-sdk-rails 3.3.1 and aws-sdk-sqs 1.34.0 on a 2015 Macbook Pro dual-core i7 with 16GB ram.

*AWS SQS ActiveJob* (default settings): Throughput 119.1 jobs/sec
*Shoryuken* (default settings): Throughput 76.8 jobs/sec

### Running workers - polling for jobs
To start processing jobs, you need to start a separate process
(in additional to your Rails app) with `bin/aws_sqs_active_job`
(an executable script provided with this gem).  You need to specify the queue to
process jobs from:
```sh
RAILS_ENV=development bundle exec aws_sqs_active_job --queue default
```

To see a complete list of arguments use `--help`.  

You can kill the process at any time with `CTRL+C` - the processor will attempt
to shutdown cleanly and will wait up to `:shutdown_timeout` seconds for all
actively running jobs to finish before killing them.


Note: When running in production, its recommended that use a process
supervisor such as [foreman](https://github.com/ddollar/foreman), systemd,
upstart, daemontools, launchd, runit, ect.  

### Serverless workers: processing activejobs using AWS Lambda
Rather than managing the worker processes yourself, you can use Lambda with an SQS Trigger.
With [Lambda Container Image Support](https://aws.amazon.com/blogs/aws/new-for-aws-lambda-container-image-support/)
and the lambda handler provided with `aws-sdk-rails` its easy to use lambda to run ActiveJobs for your dockerized
rails app (see below for some tips).  All you need to do is:
1. include the [aws_lambda_ric gem](https://github.com/aws/aws-lambda-ruby-runtime-interface-client)
2. Push your image to ecr
3. Create a lambda function from your image (see the lambda docs for details).
4. Add an SQS Trigger for the queue(s) you want to process jobs from.
5. Set the ENTRYPOINT to `/usr/local/bundle/bin/aws_lambda_ric` and the CMD
to `config/environment.Aws::Rails::SqsActiveJob.lambda_job_handler` - this will load Rails and
then use the lambda handler provided by `aws-sdk-rails.` You can do this either as function config
or in your Dockerfile.

There are a few
[limitations/requirements](https://docs.aws.amazon.com/lambda/latest/dg/images-create.html#images-reqs)
for lambda container images: the default lambda user must be able
to read all the files and the image must be able to run on a read only file system.
You may need to disable bootsnap, set a HOME env variable and
set the logger to STDOUT (which lambda will record to cloudwatch for you).

You can use the RAILS_ENV to control environment.  If you need to execute
specific configuration in the lambda, you can create a ruby file and use it
as your entrypoint:

```ruby
# app.rb
# some custom config

require_relative 'config/environment' # load rails

# Rails.config.custom....
# Aws::Rails::SqsActiveJob.config....

# no need to write a handler yourself here, as long as
# aws-sdk-rails is loaded, you can still use the
# Aws::Rails::SqsActiveJob.lambda_job_handler

# To use this file, set CMD:  app.Aws::Rails::SqsActiveJob.lambda_job_handler
```

### Elastic Beanstalk workers: processing activejobs using worker environments

Another option for processing jobs without managing the worker process is hosting the application in a scalable
[Elastic Beanstalk worker environment](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/using-features-managing-env-tiers.html).
This SDK includes Rack middleware that can be added conditionally and which will process requests from the
SQS Daemon provided with each worker instance. The middleware will forward each request and parameters to their appropriate jobs.

To add the middleware on application startup, set the ```AWS_PROCESS_BEANSTALK_WORKER_REQUESTS``` environment variable to true
in the worker environment configuration.

To protect against forgeries, daemon requests will only be processed if they originate from localhost or the Docker host.

Periodic (scheduled) jobs are also supported with this approach without requiring any additional dependencies.
Elastic Beanstalk workers support the addition of a ```cron.yaml``` file in the application root to configure this.

Example:
```yml
version: 1
cron:
 - name: "MyApplicationJob"
   url: "/"
   schedule: "0 */12 * * *"
```

Where 'name' must be the case-sensitive class name of the job.

### Configuration

For a complete list of configuration options see the
[Aws::Rails::SqsActiveJob::Configuration](https://docs.aws.amazon.com/sdk-for-ruby/aws-sdk-rails/api/Aws/Rails/SqsActiveJob/Configuration.html)
documentation.

You can configure AWS SQS Active Job either through the yml file or
through code in your config/<env>.rb or initializers.  

For file based configuration, you can use either:
1. config/aws_sqs_active_job/<RAILS_ENV>.yml
2. config/aws_sqs_active_job.yml

The yml file supports ERB.  

To configure in code:
```ruby
Aws::Rails::SqsActiveJob.configure do |config|
  config.logger = ActiveSupport::Logger.new(STDOUT)
  config.max_messages = 5
  config.client = Aws::SQS::Client.new(region: 'us-east-1')
end
```

### Using FIFO queues

If the order in which your jobs executes is important, consider using a
[FIFO Queue](https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/FIFO-queues.html).
A FIFO queue ensures that messages are processed in the order they were sent
(First-In-First-Out) and exactly-once processing (ensuring duplicates are never
introduced into the queue).  To use a fifo queue, simply set the queue url (which will end in ".fifo")
in your config.

When using FIFO queues, jobs will NOT be processed concurrently by the poller
to ensure the correct ordering.  Additionally, all jobs on a FIFO queue will be queued
synchronously, even if you have configured the `amazon_sqs_async` adapter.

#### Message Deduplication ID

FIFO queues support [Message deduplication ID](https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/using-messagededuplicationid-property.html), which is the token used for deduplication of sent messages. 
If a message with a particular message deduplication ID is sent successfully, any messages sent with the same message deduplication ID are accepted successfully but aren't delivered during the 5-minute deduplication interval.

##### Customize Deduplication keys

If necessary, the deduplication key used to create the message deduplication ID can be customized:

```ruby
Aws::Rails::SqsActiveJob.configure do |config|
  config.deduplication_keys = [:job_class, :queue_name, :arguments]
end

# Or to set deduplication keys for a single job:
class YourJob < ApplicationJob
  include Aws::Rails::SqsActiveJob
  deduplicate_with :job_class, :queue_name, :arguments
  #...
end
```

By default, the following keys are used for deduplication keys:

```
job_class, provider_job_id, queue_name, priority, arguments, executions, exception_executions, locale, timezone, enqueued_at
```

Note that `job_id` is NOT included in deduplication keys because it is unique for each initialization of the job, and the run-once behavior must be guaranteed for ActiveJob retries.

#### Message Group IDs

FIFO queues require a message group id to be provided for the job. It is determined by:
1. Calling `message_group_id` on the job if it is defined
2. If `message_group_id` is not defined or the result is `nil`, the default value will be used.
You can optionally specify a custom value in your config as the default that will be used by all jobs.

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
  [--gsi=name:hkey{ field_name }[,rkey{ field_name },proj_type{ ALL\|KEYS_ONLY\|INCLUDE }]...]  | Allows for the declaration of secondary indexes
  [--required=field1...]                                                                | A list of attributes that are required for an instance of the model
  [--length-validations=field1:MIN-MAX...]                                              | Validations on the length of attributes in a model
  [--table-name=name] | Sets the name of the table in DynamoDB, if different than the model name
  [--skip-table-config] | Doesn't generate a table config for the model
  [--password-digest] | Adds a password field (note that you must have bcrypt has a dependency) that automatically hashes and manages the model password

The included rake task `aws_record:migrate` will run all of the migrations in `app/db/table_config`
