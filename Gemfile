# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

group :development do
  gem 'rubocop'
end

group :test do
  # https://github.com/flavorjones/loofah/issues/266
  if RUBY_VERSION <= '2.4'
    gem 'loofah', '2.20.0'
  end

  gem 'rspec-expectations'
  gem 'rspec-mocks'
  gem 'bcrypt'
end

group :docs do
  gem 'yard'
  gem 'yard-sitemap', '~> 1.0'
end

group :release do
  gem 'octokit'
end
