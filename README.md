# AWS SDK for Ruby Rails Plugin

[![Build
Status](https://travis-ci.org/aws/aws-sdk-rails.png?branch=master)](https://travis-ci.org/aws/aws-sdk-rails)
[![Code
Climate](https://codeclimate.com/github/aws/aws-sdk-rails.png)](https://codeclimate.com/github/aws/aws-sdk-rails)

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
automatically check Amazon EC2 instance metadata for credentials. Learn more:
[IAM Roles for Amazon EC2](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/iam-roles-for-amazon-ec2.html)

# Features

## AWS SDK uses the Rails logger

The AWS SDK is automatically configured to use the built-in Rails logger for any
SDK log output. The logger is configured to use the `:info` log level. You can
change the log level by setting `:log_level` in the
[Aws.config](https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws.html) hash.

```ruby
Aws.config.update(log_level: :debug)
```

## Rails 5.2+ Encrypted Credentials

If you are using Rails 5.2+ [Encrypted
Credentials](http://guides.rubyonrails.org/security.html#custom-credentials),
the credentials will be automatically loaded assuming the decrypted contents
are provided as such:

```yml
# config/credentials.yml.enc
# viewable with: `rails credentials:edit`
aws:
  access_key_id: YOUR_KEY_ID
  secret_access_key: YOUR_ACCESS_KEY
```

## Amazon Simple Email Service (SES) as an ActionMailer Delivery Method

This gem will automatically register SES as an ActionMailer delivery method. You
simply need to configure Rails to use it in your environment configuration:

```ruby
# for e.g.: config/environments/production.rb
config.action_mailer.delivery_method = :ses
```

# Other Usage

## Manually setting Action Mailer credentials

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

## Using ARNs with SES

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
