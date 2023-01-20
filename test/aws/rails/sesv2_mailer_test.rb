# frozen_string_literal: true

require 'test_helper'
require 'mail'

module Aws
  module Rails
    describe Sesv2Mailer do
      let(:client_options) do
        {
          stub_responses: {
            send_email: {
              message_id: ses_message_id
            }
          }
        }
      end

      let(:mailer) { Sesv2Mailer.new(client_options) }

      let(:sample_message_from) { 'sender@example.com' }
      let(:sample_message) do
        TestMailer.deliverable(
          delivery_method: :sesv2,
          body: 'Hallo',
          from: sample_message_from,
          subject: 'This is a test',
          to: 'recipient@example.com',
          cc: 'recipient_cc@example.com',
          bcc: 'recipient_bcc@example.com',
          headers: {
            'X-SES-CONFIGURATION-SET' => 'TestConfigSet',
            'X-SES-LIST-MANAGEMENT-OPTIONS' => 'contactListName; topic=topic'
          }
        )
      end

      let(:ses_message_id) do
        '0000000000000000-1111111-2222-3333-4444-555555555555-666666'
      end

      before do
        Aws::Rails.add_action_mailer_delivery_method(:sesv2, client_options)
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
          expect(mailer_data[:from_email_address]).to eq 'sender@example.com'
          expect(mailer_data[:destination][:bcc_addresses]).to eq(
            ['recipient@example.com',
             'recipient_cc@example.com',
             'recipient_bcc@example.com']
          )
        end

        it 'delivers the message with SMTP envelope sender and recipient' do
          message = sample_message
          message.smtp_envelope_from = 'envelope-sender@example.com'
          message.smtp_envelope_to = 'envelope-recipient@example.com'
          mailer_data = mailer.deliver!(message).context.params
          expect(mailer_data[:from_email_address]).to eq 'envelope-sender@example.com'
          expect(mailer_data[:destination][:bcc_addresses]).to eq ['envelope-recipient@example.com']
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

        describe 'when sender includes name+address' do
          let(:sample_message_from) { 'Some Sender <sender@example.com>' }

          before do
            allow(sample_message).to receive(:from_address) { sample_message_from }
          end

          describe 'with SMTP envelope sender matching From header address' do
            it 'delivers the message with From header' do
              message = sample_message
              message.smtp_envelope_from = 'sender@example.com'
              mailer_data = mailer.deliver!(message).context.params
              expect(mailer_data[:from_email_address]).to eq 'Some Sender <sender@example.com>'
            end
          end

          describe 'with SMTP envelope sender different to From header address' do
            it 'delivers the message with SMTP envelope sender' do
              message = sample_message
              message.smtp_envelope_from = 'envelope-sender@example.com'
              mailer_data = mailer.deliver!(message).context.params
              expect(mailer_data[:from_email_address]).to eq 'envelope-sender@example.com'
            end
          end
        end
      end
    end
  end
end
