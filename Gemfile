# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

group :development, :test do
  gem 'pry'
end

group :development do
  gem 'rubocop'
end

group :test do
  gem 'bcrypt'
  gem 'rspec-rails'
  gem 'activerecord-jdbcsqlite3-adapter', '~> 70.0', platform: :jruby
  gem 'sqlite3', '~> 1.6', platform: :mri
  gem 'webmock'
end

group :docs do
  gem 'yard'
  gem 'yard-sitemap', '~> 1.0'
end

group :release do
  gem 'octokit'
end
