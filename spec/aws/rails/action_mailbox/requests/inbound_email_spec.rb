# frozen_string_literal: true

require 'test_helper'

describe 'inbound email', type: :request do
  let(:inbound_email_url) { '/rails/action_mailbox/ses/inbound_emails' }

  before do
    stub_request(
      :get,
      'https://sns.eu-west-1.amazonaws.com/SimpleNotificationService-a86cb10b4e1f29c941702d737128f7b6.pem'
    ).and_return(body: fixture_for(:certificate, type: :pem))
  end

  it 'receives inbound email' do
    post inbound_email_url, params: JSON.parse(fixture_for(:inbound_email, type: :json)), as: :json

    expect(response).to have_http_status(:no_content)
    expect(ActionMailbox::InboundEmail.count).to eql 1
  end

  it 'receives an inbound email with data in s3' do
    s3_email = fixture_for(:s3_email, type: :txt)

    s3_client = Aws::S3::Client.new(stub_responses: true)
    s3_client.stub_responses(:head_object, { content_length: s3_email.size, parts_count: 1 })
    s3_client.stub_responses(:get_object, { body: s3_email })

    allow(Aws::S3::Client).to receive(:new).and_return(s3_client)

    expect do
      post inbound_email_url,
           params: JSON.parse(fixture_for(:inbound_email_s3, type: :json)),
           as: :json
    end.to change(ActionMailbox::InboundEmail, :count).by(1)

    expect(response).to have_http_status(:no_content)

    inbound_email = ActionMailbox::InboundEmail.last
    expect(s3_email).to eq(inbound_email.raw_email.download)
  end
end
