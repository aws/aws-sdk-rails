# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/spec'
require 'rspec/mocks/minitest_integration'
require 'rspec/expectations/minitest_integration'

ENV['RAILS_ENV'] = 'test'
require_relative 'dummy/config/application'

ENV['AWS_REGION'] = 'us-stubbed-1'

Rails.application.initialize!
