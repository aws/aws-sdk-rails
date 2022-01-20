# frozen_string_literal: true

require 'rails'
require 'active_job/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'aws-sdk-rails'

module Dummy
  class Application < Rails::Application
    config.load_defaults Rails::VERSION::STRING.to_f
    config.eager_load = false
    config.require_master_key = true

    config.active_job.queue_adapter = :amazon
  end
end
