# AWS SDK for Ruby Rails Plugin

[![Build Status](https://travis-ci.org/aws/aws-sdk-rails.png?branch=master)](https://travis-ci.org/aws/aws-sdk-rails) [![Code Climate](https://codeclimate.com/github/aws/aws-sdk-rails.png)](https://codeclimate.com/github/aws/aws-sdk-rails)

A Ruby on Rails plugin that integrates AWS services with your Rails application
using the AWS SDK for Ruby Version 3.

## Usage

Simply require this in your Rails project's Gemfile, and AWS SDK features will
be added to your Rails environment:

```ruby
gem 'aws-sdk-rails'
```
This `aws-sdk-rails` brings in the `aws-sdk-ses` and `aws-sdk-pinpointemail` gems. This dependency
will automatically pull the `aws-sdk-core` gem for version 3 of the AWS SDK for Ruby. You will still
need to add other service gems you need to your Gemfile. For example:

```ruby
gem 'aws-sdk-rails'
gem 'aws-sdk-s3'
```

You will have to ensure that you provide credentials for the SDK to use. See the
[AWS SDK for Ruby V3 Docs](https://docs.aws.amazon.com/sdk-for-ruby/v3/api/index.html#Configuration)
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
Aws::Rails.add_action_mailer_delivery_method(:ses_mailer, credentials: creds, region: 'us-east-1')
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
Aws::Rails.add_action_mailer_delivery_method(:ses_mailer, credentials: creds, region: "us-east-1")
```

If you're running your Ruby on Rails application on Amazon Elastic Compute
Cloud, keep in mind that the AWS SDK for Ruby will automatically check Amazon
EC2 instance metadata for credentials. Learn more:
[IAM Roles for Amazon EC2](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/iam-roles-for-amazon-ec2.html)

## AWS SDK for Ruby Logging Uses the Rails Logger

Automatically, the AWS SDK for Ruby will be configured to use the built-in Rails
logger for any SDK log output.

## Using Amazon SES or Amazon Pinpoint as an ActionMailer Delivery Method

The gem will set this up automatically, with an example of doing this manually
above. With the delivery method in place, you simply need to configure Rails
to use SES as a delivery method in your environment configuration:

```ruby
# for e.g.: RAILS_ROOT/config/environments/production.rb
config.action_mailer.delivery_method = :ses_mailer
```

or for Pinpoint delivery

```ruby
# for e.g.: RAILS_ROOT/config/environments/production.rb
config.action_mailer.delivery_method = :pinpoint_mailer
```


With this in place, the AWS SDK's SES or Pinpoint client will be used by ActionMailer.

## Troubleshooting delivery

If you want to test locally be sure to modify your mailer settings on development

```ruby
# for e.g.: RAILS_ROOT/config/environments/development.rb
config.action_mailer.delivery_method = :ses_mailer
# Make sure rails doesn't swallow any connection/permissions issues with AWS
config.action_mailer.raise_delivery_errors = true
config.action_mailer.perform_deliveries = true
```

It is important to note that you're using an IAM role/user/instance profile that
it has granted permissions for `ses:SendRawEmail`
