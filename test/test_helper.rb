require 'rails/all'
require 'aws-sdk-rails'
require 'minitest/autorun'

ENV["RAILS_ENV"] = "test"

module Dummy
  class Application < Rails::Application
    config.root = File.join(__dir__, "dummy")
    config.load_defaults Rails::VERSION::STRING.to_f
    config.eager_load = false
  end
end

Rails.application.initialize!
