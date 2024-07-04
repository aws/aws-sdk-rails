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
  if defined?(JRUBY_VERSION)
    gem 'activerecord-jdbcsqlite3-adapter'
  else
    gem 'sqlite3', '~> 1.4'
  end
  gem 'webmock'
end

group :docs do
  gem 'yard'
  gem 'yard-sitemap', '~> 1.0'
end

group :release do
  gem 'octokit'
end
