# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

gem 'aws-actiondispatch-dynamodb', git: 'https://github.com/aws/aws-actiondispatch-dynamodb-ruby', branch: 'init'
gem 'aws-actionmailer-ses', git: 'https://github.com/aws/aws-actionmailer-ses-ruby'

group :development, :test do
  gem 'pry'
end

group :development do
  gem 'byebug', platforms: :ruby
  gem 'rubocop'
end

group :test do
  gem 'bcrypt'
  gem 'minitest-spec-rails'
  gem 'rspec-rails'
  gem 'webmock'
end

group :docs do
  gem 'yard'
  gem 'yard-sitemap', '~> 1.0'
end

group :release do
  gem 'octokit'
end
