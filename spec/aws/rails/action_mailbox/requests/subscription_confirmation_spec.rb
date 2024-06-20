require 'test_helper'

describe 'subscription confirmation', type: :request do
  let!(:subscription_confirmation_request) do
    query = Rack::Utils.build_query(subscription_params)
    stub_request(:get, "https://sns.eu-west-1.amazonaws.com/?#{query}")
  end

  let(:subscription_params) do
    {
      Action: 'ConfirmSubscription',
      Token: 'abcd1234' * 32,
      TopicArn: "arn:aws:sns:eu-west-1:111111111111:#{topic}"
    }
  end

  let(:topic) { 'example-topic' }

  let(:action) do
    post '/rails/action_mailbox/amazon/inbound_emails',
         headers: { 'Content-Type' => 'application/json' },
         params: fixture(type, :json)
  end

  before do
    stub_request(
      :get,
      'https://sns.eu-west-1.amazonaws.com/SimpleNotificationService-a86cb10b4e1f29c941702d737128f7b6.pem'
    ).and_return(body: fixture(:certificate, :pem))
  end

  describe 'valid Amazon SSL signature' do
    let(:type) { 'valid_signature' }
    it 'fetches subscription URL' do
      action
      expect(subscription_confirmation_request).to have_been_requested
    end
  end

  describe 'invalid Amazon SSL signature' do
    let(:type) { 'invalid_signature' }
    it 'does not fetch subscription URL' do
      action
      expect(subscription_confirmation_request).to_not have_been_requested
    end
  end

  describe 'unrecognized topic' do
    let(:type) { 'unrecognized_topic_subscription_request' }
    let(:topic) { 'unrecognized-topic' }
    it 'does not fetch subscription URL' do
      action
      expect(subscription_confirmation_request).to_not have_been_requested
    end
  end

  describe 'recognized topic' do
    let(:type) { 'recognized_topic_subscription_request' }
    let(:topic) { 'recognized-topic' }
    it 'fetches subscription URL' do
      action
      expect(subscription_confirmation_request).to have_been_requested
    end
  end
end
