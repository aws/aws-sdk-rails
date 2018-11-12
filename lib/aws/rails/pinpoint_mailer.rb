require 'aws-sdk-pinpointemail'

module Aws
  module Rails

    # Provides a delivery method for ActionMailer that uses Amazon Simple Email
    # Service.
    # 
    # Once you have an PinpointEmail delivery method you can configure Rails to
    # use this for ActionMailer in your environment configuration
    # (e.g. RAILS_ROOT/config/environments/production.rb)
    #
    #     config.action_mailer.delivery_method = :pinpoint_mailer
    #
    # Uses the AWS SDK for Ruby V3's credential provider chain when creating an
    # PinpointEmail client instance.
    class PinpointMailer

      # @param [Hash] options Passes along initialization options to
      #   [Aws::PinpointEmail::Client.new](https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/PinpointEmail/Client.html#initialize-instance_method).
      def initialize(options = {})
        @client = PinpointEmail::Client.new(options)
      end

      # Rails expects this method to exist, and to handle a Mail::Message object
      # correctly. Called during mail delivery.
      def deliver!(message)
        send_opts = {}

        #https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/PinpointEmail/Types/EmailContent.html
        send_opts[:content] = {}
        send_opts[:content][:raw] = { data: message.to_s }
        
        # https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/PinpointEmail/Types/Destination.html
        send_opts[:destination] = {}
        send_opts[:destination][:to_addresses] = [*message.to]
        send_opts[:destination][:cc_addresses] = [*message.cc]
        send_opts[:destination][:bcc_addresses] = [*message.bcc]

        @client.send_email(send_opts)
      end

      # ActionMailer expects this method to be present and to return a hash.
      def settings
        {}
      end

    end
  end
end
