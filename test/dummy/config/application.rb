# frozen_string_literal: true

require 'rails/all'
require 'aws-sdk-rails'

module Dummy
  class Application < Rails::Application
    config.load_defaults Rails::VERSION::STRING.to_f
    config.eager_load = false
    config.require_master_key = true
  end
end
