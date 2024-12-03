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
gem 'aws-sdk-rails', '~> 5'
```

This gem also brings in the following AWS gems:

* `aws-sdk-core`

You will have to ensure that you provide credentials for the SDK to use. See the
latest [AWS SDK for Ruby Docs](https://docs.aws.amazon.com/sdk-for-ruby/v3/api/index.html#Configuration)
for details.

If you're running your Rails application on Amazon EC2, the AWS SDK will
check Amazon EC2 instance metadata for credentials to load. Learn more:
[IAM Roles for Amazon EC2](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/iam-roles-for-amazon-ec2.html)

# Features

## ActionDispatch DynamoDB Session Storage

See https://github.com/aws/aws-actiondispatch-dynamodb-ruby

## ActionMailer delivery with Amazon Simple Email Service

See https://github.com/aws/aws-actionmailer-ses-ruby

## ActionMailbox ingress with Amazon Simple Email Service

See https://github.com/aws/aws-actionmailbox-ses-ruby

## ActiveJob SQS adapter

See https://github.com/aws/aws-activejob-sqs-ruby

## AWS Record Generators

See https://github.com/aws/aws-record-rails

## AWS SDK uses the Rails logger

The AWS SDK is configured to use the built-in Rails logger for any
SDK log output. The logger is configured to use the `:info` log level. You can
change the log level by setting `:log_level` in the
[Aws.config](https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws.html) hash.

```ruby
Aws.config.update(log_level: :debug)
```

## Rails 5.2+ Encrypted Credentials

If you are using [Encrypted Credentials](http://guides.rubyonrails.org/security.html#custom-credentials),
the credentials will be decrypted and loaded under the `:aws` top level key:

```yml
# config/credentials.yml.enc
# viewable with: `bundle exec rails credentials:edit`
aws:
  access_key_id: YOUR_KEY_ID
  secret_access_key: YOUR_ACCESS_KEY
  session_token: YOUR_SESSION_TOKEN
  account_id: YOUR_ACCOUNT_ID
```

Encrypted Credentials will take precedence over any other AWS Credentials that
may exist in your environment (e.g. credentials from profiles set in `~/.aws/credentials`).

If you are using [ActiveStorage](https://edgeguides.rubyonrails.org/active_storage_overview.html)
with `S3`, then you do not need to specify your credentials in your `storage.yml`
configuration because they will be loaded automatically.

## AWS SDK eager loading

An initializer will eager load the AWS SDK for you. To enable eager loading,
add the following to your `config/application.rb`:

```ruby
config.eager_load = true
```

## ActiveSupport Notifications for AWS SDK calls

[ActiveSupport::Notifications](https://api.rubyonrails.org/classes/ActiveSupport/Notifications.html)
instrumentation is enabled by default for all AWS SDK calls. Events are
published for each client operation call with the following event name:
`<operation>.<serviceId>.aws`. For example, S3's `:put_object` has an event name
of: `put_object.S3.aws`. The service name will always match the namespace of the
service client (e.g. Aws::S3::Client => 'S3'). The payload of the event is the
[request context](https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Seahorse/Client/RequestContext.html).

You can subscribe to these events as you would for other
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

### Elastic Beanstalk ActiveJob processing

[Elastic Beanstalk worker environments](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/using-features-managing-env-tiers.html)
can be used to run ActiveJob without managing a worker process. To do this,
[configure the worker](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/using-features-managing-env-tiers.html#using-features-managing-env-tiers-worker-settings)
to read from the correct SQS queue that you want to process jobs from and set
the `AWS_PROCESS_BEANSTALK_WORKER_REQUESTS` environment variable to `true` in
the worker environment configuration. The
[SQS Daemon](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/using-features-managing-env-tiers.html#worker-daemon)
running on the worker sends messages as a POST request to `http://localhost/`.
The ElasticBeanstalkSQSD middleware will forward each request and parameters to their
appropriate jobs. The middleware will only process requests from the SQS daemon
and will pass on others and so will not interfere with other routes in your
application.

To protect against forgeries, daemon requests will only be processed if they
originate from localhost or the Docker host.

#### Running Jobs Async
By default the ElasticBeanstalkSQSD middleware will process jobs synchronously
and will not complete the request until the job has finished executing.  For
long running jobs (exceeding the configured nginix timeout on the worker) this
may cause timeouts and incomplete executions.  

To run jobs asynchronously, set the `AWS_PROCESS_BEANSTALK_WORKER_JOBS_ASYNC`
environment variable to `true` in your worker environment.  Jobs will be queued
in a ThreadPoolExecutor and the request will return a 200 OK immediately and the
SQS message will be deleted and the job will be executed in the background.

By default the executor will use the available processor count as the the
max_threads.  You can configure the max threads for the executor by setting
the `AWS_PROCESS_BEANSTALK_WORKER_THREADS` environment variable.

When there is no additional capacity to execute a task, the middleware
returns a 429 (too many requests) response which will result in the 
sqsd NOT deleting the message.  The mesagge will be retried again once its
visibility timeout is reached.

#### Periodic (scheduled) jobs
Periodic (scheduled) jobs are also supported with this approach. Elastic
Beanstalk workers support the addition of a `cron.yaml` file in the application
root to configure this. You can call your jobs from your controller actions
or if you name your cron job the same as your job class and set the URL to
`/`, the middleware will automatically call the job.

Example:
```yml
version: 1
cron:
 - name: "do some task"
   url: "/scheduled"
   schedule: "0 */12 * * *"
 - name: "SomeJob"
   url: "/"
   schedule: "* * * * *"
```

and in your controller:

```ruby
class SomeController < ApplicationController
  def scheduled
    SomeJob.perform_later
  end
end
```

Will execute cron `SomeJob` every minute and `SomeJob` every 12 hours via the
`/scheduled` endpoint.
