require_relative 'aws/rails/mailer'

module Aws
  module Rails

    # @api private
    class Railtie < ::Rails::Railtie
      initializer "aws-sdk-rails.initialize", before: :load_config_initializers do |app|
        # Initialization Actions
        Aws::Rails.add_action_mailer_delivery_method
        Aws::Rails.log_to_rails_logger
      end
    end

    # This is called automatically from the SDK's Railtie, but if you want to
    # manually specify options for building the Aws::SES::Client object, you
    # can manually call this method.
    #
    # @param [Symbol] name The name of the ActionMailer delivery method to
    #   register.
    # @param [Hash] options The options you wish to pass on to the
    #   Aws::SES::Client initialization method.
    def self.add_action_mailer_delivery_method(name = :aws_sdk, options = {})
      ActiveSupport.on_load(:action_mailer) do
        self.add_delivery_method(name, Aws::Rails::Mailer, options)
      end
    end

    # Configures the AWS SDK for Ruby's logger to use the Rails logger.
    def self.log_to_rails_logger
      Aws.config[:logger] = ::Rails.logger
      nil
    end

  end
end

