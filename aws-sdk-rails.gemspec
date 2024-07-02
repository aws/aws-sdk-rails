# frozen_string_literal: true

version = File.read(File.expand_path('VERSION', __dir__)).strip

Gem::Specification.new do |spec|
  spec.name          = 'aws-sdk-rails'
  spec.version       = version
  spec.authors       = ['Amazon Web Services']
  spec.email         = ['aws-dr-rubygems@amazon.com']

  spec.summary       = 'AWS SDK for Ruby on Rails Plugin'
  spec.description   = 'Integrates the AWS Ruby SDK with Ruby on Rails'
  spec.homepage      = 'https://github.com/aws/aws-sdk-rails'
  spec.license       = 'Apache-2.0'

  spec.require_paths = ['lib']
  spec.files += Dir['lib/**/*', 'bin/*', 'app/**/*']
  spec.files << 'VERSION'
  spec.executables = ['aws_sqs_active_job']

  spec.add_dependency('aws-record', '~> 2') # for Aws::Record integration

  # Require these versions for user_agent_framework configs
  spec.add_dependency('aws-sdk-ses', '~> 1', '>= 1.50.0') # for ActionMailer
  spec.add_dependency('aws-sdk-sesv2', '~> 1', '>= 1.34.0') # for ActionMailer
  spec.add_dependency('aws-sdk-sns', '~> 1.75') # for ActionMailbox
  spec.add_dependency('aws-sdk-sqs', '~> 1', '>= 1.56.0') # for ActiveJob

  spec.add_dependency('actionmailbox', '>= 7.0.0')
  spec.add_dependency('aws-sessionstore-dynamodb', '~> 2') # includes DynamoDB
  spec.add_dependency('concurrent-ruby', '>= 1.3.1') # Utilities for concurrent processing
  spec.add_dependency('railties', '>= 7.0.0') # encrypted credentials

  spec.add_runtime_dependency('aws-sdk-s3', '~> 1.152')

  spec.add_development_dependency('pry')
  spec.add_development_dependency('rails')
  spec.add_development_dependency('rspec-rails', '~> 6.1')
  spec.add_development_dependency('sqlite3', '~> 1.4')
  spec.add_development_dependency('webmock')

  spec.required_ruby_version = '>= 2.7'
end
