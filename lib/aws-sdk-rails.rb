# frozen_string_literal: true

require_relative 'aws/rails/mailer'
require_relative 'aws/rails/notifications_instrument_plugin'

module Aws

  # Use the Rails namespace.
  module Rails

    class Configuration
      def initialize
        @notification_instrumentation = :all
      end

      attr_accessor :notification_instrumentation
    end

    def self.configure(&block)
      block.call(config)
    end

    def self.config
      @config ||= Configuration.new
    end

    # @api private
    class Railtie < ::Rails::Railtie
      initializer 'aws-sdk-rails.initialize',
                  before: :load_config_initializers do
        # Initialization Actions
        Aws::Rails.use_rails_encrypted_credentials
        Aws::Rails.add_action_mailer_delivery_method
        Aws::Rails.log_to_rails_logger
        Aws::Rails.add_notifications_instrument_plugin
      end
    end

    # This is called automatically from the SDK's Railtie, but can be manually
    # called if you want to specify options for building the Aws::SES::Client.
    #
    # @param [Symbol] name The name of the ActionMailer delivery method to
    #   register.
    # @param [Hash] options The options you wish to pass on to the
    #   Aws::SES::Client initialization method.
    def self.add_action_mailer_delivery_method(name = :ses, options = {})
      ActiveSupport.on_load(:action_mailer) do
        add_delivery_method(name, Aws::Rails::Mailer, options)
      end
    end

    # Configures the AWS SDK for Ruby's logger to use the Rails logger.
    def self.log_to_rails_logger
      Aws.config[:logger] = ::Rails.logger
      nil
    end

    # Configures the AWS SDK with credentials from Rails encrypted credentials.
    def self.use_rails_encrypted_credentials
      # limit the config keys we merge to credentials only
      aws_credential_keys = %i[access_key_id secret_access_key session_token]

      Aws.config.merge!(
        ::Rails.application
          .try(:credentials)
          .try(:aws)
          .to_h.slice(*aws_credential_keys)
      )
    end
    
    def self.add_notifications_instrument_plugin
      return if Aws::Rails.config.notification_instrumentation == :none

      Aws.constants.each do|c|
        m = Aws.const_get(c)
        if m.is_a?(Module) &&
           m.const_defined?(:Client) &&
           m.const_get(:Client).superclass == Seahorse::Client::Base
          m.const_get(:Client).add_plugin(Aws::Rails::NotificationsInstrument)
        end
      end
    end
  end
end
