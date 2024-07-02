# frozen_string_literal: true

require 'test_helper'

describe Aws::Rails::ActionMailbox::RSpec::SubscriptionConfirmation do
  let(:subscription) { described_class.new(authentic: authentic, topic: topic) }

  let(:authentic) { true }
  let(:topic) { 'topic:arn:default' }
  let(:expected_params) do
    {
      'Type' => 'SubscriptionConfirmation',
      'TopicArn' => topic,
      'SubscribeURL' => 'http://example.com/subscribe'
    }
  end

  it 'has the correct data' do
    expect(subscription.url).to eq('/rails/action_mailbox/amazon/inbound_emails')
    expect(subscription.headers).to eq('content-type' => 'application/json')
    expect(subscription.params).to eq(expected_params)
  end

  describe '#authentic?' do
    subject(:subscription_authentic) { subscription.authentic? }

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
      expect(subscription.params).to include('TopicArn' => topic)
    end
  end
end
