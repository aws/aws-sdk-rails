# frozen_string_literal: true

require 'aws-sdk-sesv2'

module Aws
  module Rails
    # Provides a delivery method for ActionMailer that uses Amazon Simple Email
    # Service V2.
    #
    # Once you have an SESv2 delivery method you can configure Rails to
    # use this for ActionMailer in your environment configuration
    # (e.g. RAILS_ROOT/config/environments/production.rb)
    #
    #     config.action_mailer.delivery_method = :sesv2
    #
    # Uses the AWS SDK for Ruby's credential provider chain when creating an SESV2
    # client instance.
    class Sesv2Mailer
      # @param [Hash] options Passes along initialization options to
      #   [Aws::SESV2::Client.new](https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/SESV2/Client.html#initialize-instance_method).
      def initialize(options = {})
        @client = SESV2::Client.new(options)
      end

      # Rails expects this method to exist, and to handle a Mail::Message object
      # correctly. Called during mail delivery.
      def deliver!(message)
        params = { content: { raw: { data: message.to_s } } }
        @client.send_email(params).tap do |response|
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
