require 'aws-sdk'

module Aws
  module Rails

    autoload :Mailer, 'aws/rails/mailer'

    # @api private
    class Railtie < ::Rails::Railtie
      initializer "aws-sdk-rails.initialize" do |app|
        # Initialization Actions
        Aws::Rails.add_action_mailer_delivery_method
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

  end
end

