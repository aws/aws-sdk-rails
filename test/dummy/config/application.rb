# frozen_string_literal: true

require 'rails'
require 'aws-sdk-rails'

module Dummy
  class Application < Rails::Application
    config.load_defaults Rails::VERSION::STRING.to_f
    config.eager_load = false
    config.secret_key_base = 'secret'
  end
end
