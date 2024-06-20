require 'test_helper'

describe 'inbound email', type: :request do
  let(:inbound_email_url) { '/rails/action_mailbox/amazon/inbound_emails' }

  before do
    stub_request(
      :get,
      'https://sns.eu-west-1.amazonaws.com/SimpleNotificationService-a86cb10b4e1f29c941702d737128f7b6.pem'
    ).and_return(body: fixture(:certificate, :pem))
  end

  it 'receives inbound email' do
    post inbound_email_url, params: JSON.parse(fixture(:inbound_email, :json)), as: :json

    expect(response).to have_http_status(:no_content)
    expect(ActionMailbox::InboundEmail.count).to eql 1
  end

  it 'receives an inbound email with data in s3' do
    s3_email = fixture(:s3_email, :txt)

    Aws.config[:s3] = {
      stub_responses: {
        head_object: { content_length: s3_email.size, parts_count: 1 },
        get_object: { body: s3_email }
      }
    }

    expect do
      post inbound_email_url,
           params: JSON.parse(fixture(:inbound_email_s3, :json)),
           as: :json
    end.to change(ActionMailbox::InboundEmail, :count).by(1)

    expect(response).to have_http_status(:no_content)

    inbound_email = ActionMailbox::InboundEmail.last
    expect(s3_email).to eq(inbound_email.raw_email.download)
  end
end
