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
  # JDBC versions track Rails versions
  if ENV['RAILS_VERSION'] == '7.0'
    gem 'activerecord-jdbcsqlite3-adapter', '~> 70.0', platform: :jruby
  elsif ENV['RAILS_VERSION'] == '7.1'
    gem 'activerecord-jdbc-adapter', '~> 71.0',
        platform: :jruby,
        # this is not published for some reason
        git: 'https://github.com/jruby/activerecord-jdbc-adapter',
        glob: 'activerecord-jdbc-adapter.gemspec'
    gem 'activerecord-jdbcsqlite3-adapter', '~> 71.0',
        platform: :jruby,
        # this is not published for some reason
        git: 'https://github.com/jruby/activerecord-jdbc-adapter',
        glob: 'activerecord-jdbcsqlite3-adapter/activerecord-jdbcsqlite3-adapter.gemspec'
  end
  # last supported version of sqlite3
  if RUBY_VERSION <= '2.7'
    gem 'sqlite3', '~> 1.6.0', platform: :ruby
  else
    gem 'sqlite3', platform: :ruby
  end

  gem 'bcrypt'
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
