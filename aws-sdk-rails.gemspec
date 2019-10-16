# frozen_string_literal: true

version = File.read(File.expand_path('VERSION', __dir__)).strip

Gem::Specification.new do |spec|
  spec.name          = 'aws-sdk-rails'
  spec.version       = version
  spec.authors       = ['Amazon Web Services']
  spec.email         = ['chejingy@amazon.com', 'mamuller@amazon.com']
  spec.summary       = 'AWS SDK for Ruby on Rails Plugin'
  spec.description   = 'Integrates the AWS Ruby SDK with Ruby on Rails'
  spec.homepage      = 'https://github.com/aws/aws-sdk-rails'
  spec.license       = 'Apache 2.0'

  spec.require_paths = ['lib']
  spec.files += Dir['lib/**/*.rb', 'lib/aws_sdk_rails.rb']

  spec.add_dependency('aws-sdk-ses', '~> 1')
  spec.add_dependency('railties', '>= 5.2')

  spec.add_development_dependency('rails')
end
