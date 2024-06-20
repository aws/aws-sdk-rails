require 'test_helper'

describe Aws::Rails::ActionMailbox::RSpec::Email do
  let(:email) { described_class.new(authentic: authentic, mail: mail, topic: topic) }
  let(:topic) { 'topic:arn:default' }
  let(:authentic) { true }
  let(:mail) { instance_double(Mail::Message, encoded: 'raw encoded email') }
  let(:expected_params) do
    {
      'Type' => 'Notification',
      'TopicArn' => topic,
      'Message' => {
        'notificationType' => 'Received',
        'content' => 'raw encoded email'
      }.to_json
    }
  end

  it 'has the correct data' do
    expect(email.url).to eq('/rails/action_mailbox/amazon/inbound_emails')
    expect(email.headers).to eq('content-type' => 'application/json')
    expect(email.params).to eq(expected_params)
  end

  describe '#authentic?' do
    subject(:email_authentic) { email.authentic? }

    context 'when authentic' do
      let(:authentic) { true }

      it { is_expected.to be(true) }
    end

    context 'when not authentic' do
      let(:authentic) { false }

      it { is_expected.to be(false) }
    end
  end

  context 'when custom topic' do
    let(:topic) { 'custom-topic' }

    it 'has topic' do
      expect(email.params).to include('TopicArn' => topic)
    end
  end
end
