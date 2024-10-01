# frozen_string_literal: true

ENV['RAILS_ENV'] = 'test'

require_relative '../../spec/dummy/config/environment'
require 'webmock/rspec'
require 'rspec/rails'
