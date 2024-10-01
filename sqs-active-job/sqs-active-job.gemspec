# frozen_string_literal: true

version = File.read(File.expand_path('../VERSION', __dir__)).strip

Gem::Specification.new do |spec|
  spec.name          = 'sqs-active-job'
  spec.version       = version
  spec.authors       = ['Amazon Web Services']
  spec.email         = ['aws-dr-rubygems@amazon.com']

  spec.summary       = 'AWS SDK for ActiveJob with SQS'
  spec.description   = 'Integrates the AWS Ruby SDK for SQS with ActiveJob'
  spec.homepage      = 'https://github.com/aws/aws-sdk-rails'
  spec.license       = 'Apache-2.0'

  spec.files = Dir['README.md', 'lib/**/*', 'bin/*']
  spec.require_path = 'lib'
  spec.executables = ['aws_sqs_active_job']

  # Require these versions for user_agent_framework configs
  spec.add_dependency('aws-sdk-sqs', '~> 1', '>= 1.56.0') # for ActiveJob
  spec.add_dependency('concurrent-ruby', '~> 1.3', '>= 1.3.1') # Utilities for concurrent processing
  spec.add_dependency('activejob', '>= 7.0.0') # Minimum supported Rails version

  spec.required_ruby_version = '>= 2.7'
end
