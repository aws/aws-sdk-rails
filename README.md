# AWS SDK for Ruby Rails Plugin

[![Build Status](https://travis-ci.org/aws/aws-sdk-rails.png?branch=master)](https://travis-ci.org/aws/aws-sdk-rails) [![Code Climate](https://codeclimate.com/github/aws/aws-sdk-rails.png)](https://codeclimate.com/github/aws/aws-sdk-rails)

A Ruby on Rails plugin that integrates AWS services with your Rails application
using the AWS SDK for Ruby Version 2.

## Usage

Simply require this in your Rails project's Gemfile, and AWS SDK features will
be added to your Rails environment:

```ruby
gem 'aws-sdk-rails'
```

This dependency will automatically pull in version 2 of the AWS SDK for Ruby.

You will have to ensure that you provide credentials for the SDK to use. See the
[AWS SDK for Ruby V2 Docs](http://docs.aws.amazon.com/sdkforruby/api/index.html#Credentials)
for details. If you need to provide your own credentials, you can call
client-creating actions manually. For example, to provide your own credentials
and make Amazon Simple Email Service available as a delivery method for
ActionMailer, you can create an initializer `RAILS_ROOT/config/initializers/aws_sdk.rb`
with contents similar to the following:

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
Aws::Rails.add_action_mailer_delivery_method(:aws_sdk, credentials: creds, region: 'us-east-1')
```

Or, if you are storing your AWS keys using Rails 5.2's [Encrypted
Credentials](http://guides.rubyonrails.org/security.html#custom-credentials),
use the following initializer code instead:

```ruby
# Assuming an encrypted credentials file with decrypted contents like:
#
#     aws:
#       access_key_id: YOUR_KEY_ID
#       secret_access_key: YOUR_ACCESS_KEY
#
keys = Rails.application.credentials[:aws]

creds = Aws::Credentials.new(keys[:access_key_id], keys[:secret_access_key])
Aws::Rails.add_action_mailer_delivery_method(:aws_sdk, credentials: creds, region: "us-east-1")
```

If you're running your Ruby on Rails application on Amazon Elastic Compute
Cloud, keep in mind that the AWS SDK for Ruby will automatically check Amazon
EC2 instance metadata for credentials. Learn more:
[IAM Roles for Amazon EC2](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/iam-roles-for-amazon-ec2.html)

## AWS SDK for Ruby Logging Uses the Rails Logger

Automatically, the AWS SDK for Ruby will be configured to use the built-in Rails
logger for any SDK log output.

## Using Amazon SES as an ActionMailer Delivery Method

The gem will set this up automatically, with an example of doing this manually
above. With the delivery method in place, you simply need to configure Rails
to use SES as a delivery method in your environment configuration:

```ruby
# for e.g.: RAILS_ROOT/config/environments/production.rb
config.action_mailer.delivery_method = :aws_sdk
```

With this in place, the AWS SDK's SES client will be used by ActionMailer.
