# frozen_string_literal: true

require 'aws-sdk-ses'

module Aws
  module ActionMailer
    # Provides a delivery method for ActionMailer that uses Amazon Simple Email Service.
    #
    # Configure a delivery method with:
    #
    #   client_options = { region: 'us-west-2' }
    #   ActionMailer::Base.add_delivery_method :ses, Aws::ActionMailer::SESMailer, **client_options
    #
    # Client options are used to construct a new Aws::SES::Client instance.
    #
    # Once you have a delivery method, you can configure your Rails environment to use it:
    #
    #   config.action_mailer.delivery_method = :ses
    #
    # @see https://guides.rubyonrails.org/action_mailer_basics.html
    class SESMailer
      # @param [Hash] options Passes along initialization options to
      #   [Aws::SES::Client.new](https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/SES/Client.html#initialize-instance_method).
      def initialize(options = {})
        @client = SES::Client.new(options)
        @client.config.user_agent_frameworks << 'aws-sdk-rails'
      end

      # Delivers a Mail::Message object. Called during mail delivery.
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

      # @return [Hash]
      def settings
        {}
      end
    end
  end
end
