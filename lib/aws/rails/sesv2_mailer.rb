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
        send_opts = {}
        send_opts[:content] = {}
        send_opts[:content][:raw] = { data: message.to_s }

        # Check for Rails >=6 compatibility
        send_opts[:from_email_address] = if message.respond_to?(:from_address)
                                           message.from_address&.to_s
                                         else
                                           Array.wrap(message.from).first&.to_s
                                         end

        send_opts[:destination] = {}
        send_opts[:destination][:to_addresses] = [*message.to]
        send_opts[:destination][:cc_addresses] = [*message.cc]
        send_opts[:destination][:bcc_addresses] = [*message.bcc]

        send_opts[:configuration_set_name] = message.header['X-SES-CONFIGURATION-SET']&.yield_self do |field|
          message.header.fields.delete(field).value
        end

        send_opts[:list_management_options] = message.header['X-SES-LIST-MANAGEMENT-OPTIONS']&.yield_self do |field|
          contact_list_name, topic_name = message.header.fields.delete(field).value.sub("topic=", "").split(";").map(&:strip)
          {contact_list_name: contact_list_name, topic_name: topic_name}.compact
        end

        @client.send_email(send_opts).tap do |response|
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
