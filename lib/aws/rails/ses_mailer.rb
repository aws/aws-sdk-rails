# frozen_string_literal: true

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
    #     config.action_mailer.delivery_method = :ses
    #
    # Uses the AWS SDK for Ruby's credential provider chain when creating an SES
    # client instance.
    class SesMailer
      # @param [Hash] options Passes along initialization options to
      #   [Aws::SES::Client.new](https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/SES/Client.html#initialize-instance_method).
      def initialize(options = {})
        @client = SES::Client.new(options)
      end

      # Rails expects this method to exist, and to handle a Mail::Message object
      # correctly. Called during mail delivery.
      def deliver!(message)
        params = {
          raw_message: { data: message.to_s },
          source: message.smtp_envelope_from, # defaults to From header
          destinations: message.smtp_envelope_to # defaults to destinations (To,Cc,Bcc)
        }
        @client.send_raw_email(params).tap do |response|
          message.header[:ses_message_id] = response.message_id
        end
      end

      # ActionMailer expects this method to be present and to return a hash.
      def settings
        {}
      end
    end
  end
end

# This is for backwards compatibility after introducing support for SESv2.
# The old mailer is now replaced with the new SES (v1) mailer.
Aws::Rails::Mailer = Aws::Rails::SesMailer
