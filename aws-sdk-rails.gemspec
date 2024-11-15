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
  spec.files         = Dir['LICENSE.txt', 'CHANGELOG.md', 'VERSION', 'lib/**/*']

  # These will be removed in aws-sdk-rails ~> 5
  spec.add_dependency('aws-actiondispatch-dynamodb', '~> 0')
  spec.add_dependency('aws-actionmailbox-ses', '~> 0')
  spec.add_dependency('aws-actionmailer-ses', '~> 0')
  spec.add_dependency('aws-activejob-sqs', '~> 0')

  spec.add_dependency('aws-record', '~> 2') # for Aws::Record integration

  spec.add_dependency('railties', '>= 7.1.0') # Minimum supported Rails version

  spec.required_ruby_version = '>= 2.7'
end
