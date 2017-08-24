require 'aws-sdk-ses'

module Aws
  module Rails

    # Provides a delivery method for ActionMailer that uses Amazon Simple Email
    # Service.
    # 
    # Once you have an SES delivery method you can configure Rails to
    # use this for ActionMailer in your environment configuration
    # (e.g. RAILS_ROOT/config/environments/production.rb)
    #
    #     config.action_mailer.delivery_method = :aws_sdk
    #
    # Uses the AWS SDK for Ruby V2's credential provider chain when creating an
    # SES client instance.
    class Mailer

      # @param [Hash] options Passes along initialization options to
      #   [Aws::SES::Client.new](http://docs.aws.amazon.com/sdkforruby/api/Aws/SES/Client.html#initialize-instance_method).
      def initialize(options = {})
        @client = SES::Client.new(options)
      end

      # Rails expects this method to exist, and to handle a Mail::Message object
      # correctly. Called during mail delivery.
      def deliver!(message)
        send_opts = {}
        send_opts[:raw_message] = {}
        send_opts[:raw_message][:data] = message.to_s

        if message.respond_to?(:destinations)
          send_opts[:destinations] = message.destinations
        end

        @client.send_raw_email(send_opts)

      end

      # ActionMailer expects this method to be present and to return a hash.
      def settings
        {}
      end

    end
  end
end
