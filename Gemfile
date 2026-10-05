# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

gem 'rake', require: false
if defined?(JRUBY_VERSION)
  gem 'rdoc', '< 8.0.0'
else
  gem 'rdoc'
end

case ENV.fetch('RAILS_VERSION', nil)
when '7.1'
  gem 'json', '< 3' # Not compatible with JSON 3.0 changes
  gem 'rails', '~> 7.1.0'
when '7.2'
  gem 'rails', '~> 7.2.0'
when '8.0'
  # JSON 3.0 broke ActiveSupport::JSON but fix is unreleased
  # Drop this once an 8.0.x carrying that commit ships.
  # https://github.com/rails/rails/commit/2786de26c6fe1c58a6722dd9bba856fbe249c897
  gem 'json', '< 3'
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
