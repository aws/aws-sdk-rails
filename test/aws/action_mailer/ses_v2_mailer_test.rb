# frozen_string_literal: true

require 'test_helper'

require 'mail'

module Aws
  module ActionMailer
    describe SESV2Mailer do
      let(:client_options) do
        { stub_responses: { send_email: { message_id: ses_message_id } } }
      end

      let(:mailer) { SESV2Mailer.new(client_options) }

      let(:sample_message) do
        TestMailer.deliverable(
          body: 'Hallo',
          from: 'Sender <sender@example.com>',
          subject: 'This is a test',
          to: 'Recipient <recipient@example.com>',
          cc: 'Recipient CC <recipient_cc@example.com>',
          bcc: 'Recipient BCC <recipient_bcc@example.com>',
          headers: {
            'X-SES-CONFIGURATION-SET' => 'TestConfigSet',
            'X-SES-LIST-MANAGEMENT-OPTIONS' => 'contactListName; topic=topic'
          },
          delivery_method: :ses_v2
        )
      end

      let(:ses_message_id) do
        '0000000000000000-1111111-2222-3333-4444-555555555555-666666'
      end

      before do
        ::ActionMailer::Base.add_delivery_method :ses_v2, SESV2Mailer, **client_options
      end

      describe '#settings' do
        it 'returns an empty hash' do
          expect(mailer.settings).to eq({})
        end
      end

      describe '#deliver' do
        it 'delivers the message' do
          mailer_data = mailer.deliver!(sample_message).context.params
          raw = mailer_data[:content][:raw][:data].to_s
          raw.gsub!("\r\nHallo", "ses-message-id: #{ses_message_id}\r\n\r\nHallo")
          expect(raw).to eq sample_message.to_s
          expect(mailer_data[:from_email_address]).to eq nil # Optional for raw messages
          expect(mailer_data[:destination]).to eq(
            to_addresses: ['recipient@example.com'], # Default to To header
            cc_addresses: ['recipient_cc@example.com'],
            bcc_addresses: ['recipient_bcc@example.com']
          )
        end

        it 'delivers the message with SMTP envelope sender and recipient' do
          message = sample_message.message
          message.smtp_envelope_from = 'envelope-sender@example.com'
          message.smtp_envelope_to = 'envelope-recipient@example.com'
          mailer_data = mailer.deliver!(message).context.params
          expect(mailer_data[:from_email_address]).to eq 'envelope-sender@example.com'
          expect(mailer_data[:destination]).to eq(
            to_addresses: ['envelope-recipient@example.com'],
            cc_addresses: ['recipient_cc@example.com'],
            bcc_addresses: ['recipient_bcc@example.com']
          )
        end

        it 'delivers with action mailer' do
          message = sample_message.deliver_now
          expect(message.header[:ses_message_id].value).to eq ses_message_id
        end

        it 'passes through SES headers' do
          mailer_data = mailer.deliver!(sample_message).context.params
          raw = mailer_data[:content][:raw][:data].to_s
          expect(raw).to include('X-SES-CONFIGURATION-SET: TestConfigSet')
          expect(raw).to include('X-SES-LIST-MANAGEMENT-OPTIONS: contactListName; topic=topic')
        end
      end
    end
  end
end
