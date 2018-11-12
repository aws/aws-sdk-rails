version = File.read(File.expand_path('../VERSION', __FILE__)).strip

Gem::Specification.new do |spec|
  spec.name          = "aws-sdk-rails"
  spec.version       = version
  spec.authors       = ["Amazon Web Services"]
  spec.email         = ["alexwood@amazon.com"]
  spec.summary       = "AWS SDK for Ruby Rails Plugin"
  spec.description   = "Provides helpers to integrate the AWS SDK for Ruby with Ruby on Rails."
  spec.homepage      = "https://github.com/aws/aws-sdk-rails"
  spec.license       = "Apache 2.0"

  spec.require_paths = ["lib"]
  spec.files         += Dir['lib/**/*.rb', 'lib/aws-sdk-rails.rb']

  spec.add_dependency('aws-sdk-ses')
  spec.add_dependency('aws-sdk-pinpointemail')
  spec.add_dependency('railties', '>= 3')
end
