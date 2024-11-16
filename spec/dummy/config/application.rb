# frozen_string_literal: true

require 'rails'
require 'action_mailer/railtie'
require 'action_controller/railtie'

require 'aws-sdk-rails'

module Dummy
  class Application < Rails::Application
    config.load_defaults Rails::VERSION::STRING.to_f
    config.eager_load = true
    config.require_master_key = true
  end
end
