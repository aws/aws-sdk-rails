# AWS SDK for Ruby Rails Plugin

[![Build
Status](https://travis-ci.org/aws/aws-sdk-rails.png?branch=master)](https://travis-ci.org/aws/aws-sdk-rails)
[![Code
Climate](https://codeclimate.com/github/aws/aws-sdk-rails.png)](https://codeclimate.com/github/aws/aws-sdk-rails)

A Ruby on Rails plugin that integrates AWS services with your application using
the latest version of [AWS SDK For Ruby](https://github.com/aws/aws-sdk-ruby).

## Usage

Add this gem to your Rails project's Gemfile:

```ruby
gem 'aws-sdk-rails'
```

This gem also brings in the `aws-sdk-core`, `aws-sdk-sts`, and `aws-sdk-ses`
gems. If you want to use other services (such as S3), you will still need to add
them to your Gemfile:

```ruby
gem 'aws-sdk-rails', '~> 2'
gem 'aws-sdk-s3', '~> 1'
```

You will have to ensure that you provide credentials for the SDK to use. See the
latest [AWS SDK for Ruby
Docs](https://docs.aws.amazon.com/sdk-for-ruby/v3/api/index.html#Configuration)
for details.

## Use Amazon Simple Email Service (SES) as an ActionMailer Delivery Method

This gem will automatically register SES as an ActionMailer delivery method. You
simply need to configure Rails to use it in your environment configuration:

```ruby
# for e.g.: config/environments/production.rb
config.action_mailer.delivery_method = :ses
```

## AWS SDK uses the Rails logger

The AWS SDK is automatically configured to use the built-in Rails logger for any
SDK log output.

## Providing your own credentials manually

If you need to provide your own credentials, you can call client-creating
actions manually. For example, you can create an initializer
`config/initializers/aws_sdk.rb` with contents similar to the following:

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

Aws::Rails.add_action_mailer_delivery_method(
  :ses,
  credentials: creds,
  region: 'us-east-1'
)
```

If you're running your Rails application on Amazon EC2, keep in mind that the
AWS SDK for Ruby will automatically check Amazon EC2 instance metadata for
credentials. Learn more: [IAM Roles for Amazon
EC2](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/iam-roles-for-amazon-ec2.html)
