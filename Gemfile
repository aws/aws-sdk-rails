# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

gem 'rake', require: false

case ENV.fetch('RAILS_VERSION', nil)
when '7.1'
  gem 'rails', '~> 7.1.0'
when '7.2'
  gem 'rails', '~> 7.2.0'
when '8.0'
  gem 'rails', '~> 8.0.0'
else
  gem 'rails', github: 'rails/rails'
end

group :development do
  gem 'byebug', platforms: :ruby
  gem 'pry'
  gem 'rubocop'
end

group :test do
  gem 'rspec'
end

group :docs do
  gem 'yard'
  gem 'yard-sitemap', '~> 1.0'
end

group :release do
  gem 'octokit'
end
