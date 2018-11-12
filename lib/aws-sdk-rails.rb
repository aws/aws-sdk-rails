require_relative 'aws/rails/ses_mailer'
require_relative 'aws/rails/pinpoint_mailer'
require_relative 'aws/rails/aws_sdk'

module Aws
  module Rails

    # @api private
    class Railtie < ::Rails::Railtie
      initializer "aws-sdk-rails.initialize", before: :load_config_initializers do |app|
        # Initialization Actions
        [:ses_mailer, :pinpoint_mailer, :aws_sdk].each do |name|
          Aws::Rails.add_action_mailer_delivery_method name
        end

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
    def self.add_action_mailer_delivery_method(name = :ses_mailer, options = {})
      ActiveSupport.on_load(:action_mailer) do
        self.add_delivery_method(name, "Aws::Rails::#{name.to_s.classify}".constantize, options)
      end
    end

    # Configures the AWS SDK for Ruby's logger to use the Rails logger.
    def self.log_to_rails_logger
      Aws.config[:logger] = ::Rails.logger
      nil
    end

  end
end

