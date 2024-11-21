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

  spec.add_dependency('aws-sdk-core', '~> 3')

  spec.add_dependency('railties', '>= 7.1.0')

  spec.required_ruby_version = '>= 2.7'
end
