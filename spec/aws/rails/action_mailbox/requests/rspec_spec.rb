# frozen_string_literal: true

require 'test_helper'
require 'aws/rails/action_mailbox/rspec'

describe 'rspec', type: :request do
  include Aws::Rails::ActionMailbox::RSpec

  before do
    allow(Rails.configuration.action_mailbox.ses).to receive(:subscribed_topic) { topic }
  end

  describe 'topic subscription' do
    describe 'recognized topic' do
      let(:topic) { 'topic:arn:default' }
      it 'renders 200 OK' do
        action_mailbox_ses_deliver_subscription_confirmation
        expect(response).to have_http_status :ok
      end
    end

    describe 'unrecognized topic' do
      let(:topic) { 'topic:arn:other' }
      it 'renders 401 Unauthorized' do
        action_mailbox_ses_deliver_subscription_confirmation
        expect(response).to have_http_status :unauthorized
      end
    end
  end

  describe 'email delivery' do
    describe 'when recognized topic' do
      let(:topic) { 'topic:arn:default' }
      it 'renders 204 No Content' do
        action_mailbox_ses_deliver_email(mail: Mail.new)
        expect(response).to have_http_status :no_content
      end

      it 'delivers an email to inbox' do
        action_mailbox_ses_deliver_email(mail: Mail.new(to: 'user@example.com'))
        expect(ActionMailbox::InboundEmail.last.mail.recipients).to eql ['user@example.com']
      end
    end

    describe 'when unrecognized topic' do
      let(:topic) { 'topic:arn:other' }
      it 'renders 401 Unauthorized' do
        action_mailbox_ses_deliver_email
        expect(response).to have_http_status :unauthorized
      end
    end

    describe 'with destination parameter set' do
      let(:topic) { 'topic:arn:default' }

      it 'extracts recipient email from SNS notification content' do
        action_mailbox_ses_deliver_email(
          mail: Mail.new(to: 'user@example.com'),
          message_params: { 'mail' => { 'destination' => ['bcc_user@example.com'] } }
        )

        expect(ActionMailbox::InboundEmail.last.mail.recipients).to contain_exactly(
          'user@example.com', 'bcc_user@example.com'
        )
      end
    end
  end
end
