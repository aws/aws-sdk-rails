# frozen_string_literal: true

require 'rails'
require 'action_mailer/railtie'

require 'aws-sdk-rails'
require 'aws-sessionstore-dynamodb'

module Dummy
  class Application < Rails::Application
    config.load_defaults Rails::VERSION::STRING.to_f
    config.eager_load = true
    config.secret_key_base = 'secret'
  end
end
