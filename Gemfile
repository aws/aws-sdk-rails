# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

group :development do
  gem 'rubocop'
end

group :test do
  gem 'rspec-expectations'
  gem 'rspec-mocks'
  gem 'bcrypt'
  if defined?(JRUBY_VERSION)
    gem 'activerecord-jdbcsqlite3-adapter'
  else
    gem 'sqlite3'
  end
end

group :docs do
  gem 'yard'
  gem 'yard-sitemap', '~> 1.0'
end

group :release do
  gem 'octokit'
end
