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
        send_opts = init_send_options(message)

        @client.send_email(send_opts).tap do |response|
          message.header[:ses_message_id] = response.message_id
        end
      end

      # ActionMailer expects this method to be present and to return a hash.
      def settings
        {}
      end

      private

      def init_send_options(message)
        {
          content: { raw: { data: message.to_s } },
          from_email_address: Array.wrap(message.from).first&.to_s,
          destination: extract_destinations(message),
          configuration_set_name: extract_configuration_set_from_headers(message),
          list_management_options: extract_list_management_options_from_headers(message)
        }
      end

      def extract_destinations(message)
        {
          to_addresses: [*message.to],
          cc_addresses: [*message.cc],
          bcc_addresses: [*message.bcc]
        }
      end

      def extract_configuration_set_from_headers(message)
        # From the AWS docs https://docs.aws.amazon.com/ses/latest/dg/using-configuration-sets-in-email.html
        # you can specify a configuration set by including the following header in your email
        # (replacing ConfigSet with the name of the configuration set you want to use)
        # X-SES-CONFIGURATION-SET: ConfigSet
        message.header['X-SES-CONFIGURATION-SET']&.yield_self do |field|
          message.header.fields.delete(field).value
        end
      end

      def extract_list_management_options_from_headers(message)
        # From the AWS docs: https://docs.aws.amazon.com/ses/latest/dg/sending-email-list-management.html
        # To specify a list and topic name while sending email using the SMTP interface,
        # add the following email header to your message:
        # X-SES-LIST-MANAGEMENT-OPTIONS: {contactListName}; topic={topicName}
        message.header['X-SES-LIST-MANAGEMENT-OPTIONS']&.yield_self do |field|
          header_fields = message.header.fields
          header_value = header_fields.delete(field).value

          contact_list_name, topic_name = header_value.sub('topic=', '').split(';').map(&:strip)

          { contact_list_name: contact_list_name, topic_name: topic_name }.compact
        end
      end
    end
  end
end
