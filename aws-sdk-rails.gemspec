# frozen_string_literal: true

version = File.read(File.expand_path('VERSION', __dir__)).strip

Gem::Specification.new do |spec|
  spec.name         = 'aws-sdk-rails'
  spec.version      = version
  spec.author       = 'Amazon Web Services'
  spec.email        = ['aws-dr-rubygems@amazon.com']
  spec.summary       = 'AWS SDK for Ruby on Rails Railtie'
  spec.description   = 'Integrates the AWS SDK for Ruby with Ruby on Rails'
  spec.homepage      = 'https://github.com/aws/aws-sdk-rails'
  spec.license       = 'Apache-2.0'
  spec.files         = Dir['LICENSE.txt', 'CHANGELOG.md', 'VERSION', 'lib/**/*', 'bin/*', 'app/**/*', 'config/*']
  spec.executables = ['aws_sqs_active_job']

  # These will be removed in aws-sdk-rails ~> 5
  spec.add_dependency('aws-actionmailer-ses', '~> 0')
  spec.add_dependency('aws-record', '~> 2') # for Aws::Record integration
  spec.add_dependency('aws-actiondispatch-dynamodb', '~> 0')

  # Require these versions for user_agent_framework configs
  spec.add_dependency('aws-sdk-s3', '~> 1', '>= 1.123.0')
  spec.add_dependency('aws-sdk-sns', '~> 1', '>= 1.61.0') # for ActionMailbox
  spec.add_dependency('aws-sdk-sqs', '~> 1', '>= 1.56.0') # for ActiveJob

  spec.add_dependency('actionmailbox', '>= 7.1.0') # for SES ActionMailbox
  spec.add_dependency('concurrent-ruby', '~> 1.3', '>= 1.3.1') # Utilities for concurrent processing
  spec.add_dependency('railties', '>= 7.1.0') # Minimum supported Rails version

  spec.required_ruby_version = '>= 2.7'
end
