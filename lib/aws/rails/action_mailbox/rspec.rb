# frozen_string_literal: true

require 'aws/rails/action_mailbox/rspec/email'
require 'aws/rails/action_mailbox/rspec/subscription_confirmation'
require 'aws-sdk-sns'

module Aws
  module Rails
    module ActionMailbox
      # Include the `Aws::Rails::ActionMailbox::RSpec` extension in your tests, like so:
      # require 'aws/rails/action_mailbox/rspec'
      # RSpec.configure do |config|
      #   config.include Aws::Rails::ActionMailbox::RSpec
      # end
      # Then, in a request spec, use like so:
      # RSpec.describe 'amazon emails', type: :request do
      #   it 'delivers a subscription notification' do
      #     action_mailbox_ses_deliver_subscription_confirmation
      #     expect(response).to have_http_status :ok
      #   end

      #   it 'delivers an email notification' do
      #     action_mailbox_ses_deliver_email(mail: Mail.new(to: 'user@example.com'))
      #     expect(ActionMailbox::InboundEmail.last.mail.recipients).to eql ['user@example.com']
      #   end
      # end
      module RSpec
        def action_mailbox_ses_deliver_subscription_confirmation(options = {})
          subscription_confirmation = SubscriptionConfirmation.new(**options)
          stub_aws_sns_message_verifier(subscription_confirmation)
          stub_aws_sns_subscription_request

          post subscription_confirmation.url,
               params: subscription_confirmation.params,
               headers: subscription_confirmation.headers,
               as: :json
        end

        def action_mailbox_ses_deliver_email(options = {})
          email = Email.new(**options)
          stub_aws_sns_message_verifier(email)

          post email.url,
               params: email.params,
               headers: email.headers,
               as: :json
        end

        private

        def message_verifier(subscription_confirmation)
          instance_double(Aws::SNS::MessageVerifier, authentic?: subscription_confirmation.authentic?)
        end

        def stub_aws_sns_message_verifier(notification)
          allow(Aws::Rails::ActionMailbox::SnsMessageVerifier).to receive(:verifier) { message_verifier(notification) }
        end

        def stub_aws_sns_subscription_request
          allow(Net::HTTP).to receive(:get_response).and_call_original
          allow(Net::HTTP)
            .to receive(:get_response)
              .with(URI('http://example.com/subscribe')) { double(code: '200') }
        end
      end
    end
  end
end
