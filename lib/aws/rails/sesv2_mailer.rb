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
        # smtp_envelope_from will default to the From address *without* sender names.
        # By omitting this param, SESv2 will correctly use sender names from the mail headers.
        # We should only use smtp_envelope_from when it was explicitly set (instance variable set)
        params[:from_email_address] = message.smtp_envelope_from if message.instance_variable_get(:@smtp_envelope_from)
        params[:destination] = {
          to_addresses: to_addresses(message),
          cc_addresses: message.cc,
          bcc_addresses: message.bcc
        }

        @client.send_email(params).tap do |response|
          message.header[:ses_message_id] = response.message_id
        end
      end

      # ActionMailer expects this method to be present and to return a hash.
      def settings
        {}
      end

      private

      # smtp_envelope_to will default to the full destinations (To, Cc, Bcc)
      # SES v2 API prefers each component split out into a destination hash.
      # When smtp_envelope_to was set, use it explicitly for to_address only.
      def to_addresses(message)
        message.instance_variable_get(:@smtp_envelope_to) ? message.smtp_envelope_to : message.to
      end
    end
  end
end
