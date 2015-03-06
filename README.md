# AWS SDK for Ruby Rails Plugin

A Ruby on Rails plugin that integrates AWS services with your Rails application
using the AWS SDK for Ruby Version 2.

## Usage

Simply require this in your Rails project's Gemfile, and AWS SDK features will
be added to your Rails environment:

    gem 'aws-sdk-rails'

This dependency will automatically pull in version 2 of the AWS SDK for Ruby.

You will have to ensure that you provide credentials for the SDK to use. See the
[AWS SDK for Ruby V2 Docs](http://docs.aws.amazon.com/sdkforruby/api/index.html#Credentials)
for details. If you need to provide your own credentials, you can call
client-creating actions manually. For example, to provide your own credentials
for using Amazon Simple Email Service as a delivery method for ActionMailer:

    require 'json'
    # Because you're never going to commit credentials to source. Please.
    creds = JSON.load(File.read('secrets.json'))
    creds = Aws::Credentials.new(creds['AccessKeyId'], creds['SecretAccessKey'])
    Aws::Rails.add_action_mailer_delivery_method(:aws_sdk, credentials: creds, region: 'us-east-1')
    
## Using Amazon SES as an ActionMailer Delivery Method

The gem will set this up automatically, with an example of doing this manually
above. With the delivery method in place, you simply need to configure Rails
to use SES as a delivery method in your environment configuration:

    # for e.g.: RAILS_ROOT/config/environments/production.rb
    config.action_mailer.delivery_methods = :aws_sdk

With this in place, the AWS SDK's SES client will be used by ActionMailer.
