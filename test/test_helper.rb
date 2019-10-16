# frozen_string_literal: true

require 'rails/all'
require 'aws_sdk_rails'
require 'minitest/autorun'

ENV['RAILS_ENV'] = 'test'

module Dummy
  class Application < Rails::Application
    config.root = File.join(__dir__, 'dummy')
    config.load_defaults Rails::VERSION::STRING.to_f
    config.eager_load = false
    config.require_master_key = true
  end
end

Rails.application.initialize!
