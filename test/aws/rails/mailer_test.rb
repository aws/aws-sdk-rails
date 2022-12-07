# frozen_string_literal: true

require 'test_helper'
require 'mail'

class TestMailer < ActionMailer::Base
  layout nil

  def deliverable(options = {})
    mail(delivery_method: :ses, body: '').tap do |m|
      options.each {|k, v| m.send(k, v) }
    end
  end
end

module Aws
  module Rails
    describe Mailer do
      let(:client_options) do
        {
          stub_responses: {
            send_raw_email: {
              message_id: ses_message_id
            }
          }
        }
      end

      let(:mailer) { Mailer.new(client_options) }

      let(:sample_message) do
        TestMailer.deliverable(
          body: 'Hallo',
          from: 'sender@example.com',
          smtp_envelope_from: 'envelope-sender@example.com',
          subject: 'This is a test',
          to: 'recipient@example.com',
          smtp_envelope_to: 'envelope-recipient@example.com',
        )
      end

      let(:ses_message_id) do
        '0000000000000000-1111111-2222-3333-4444-555555555555-666666'
      end

      before do
        ActionMailer::Base.add_delivery_method(:ses, Mailer, client_options)
      end

      describe '#settings' do
        it 'returns an empty hash' do
          expect(mailer.settings).to eq({})
        end
      end

      describe '#deliver' do
        it 'delivers the message' do
          mailer_data = mailer.deliver!(sample_message).context.params
          raw = mailer_data[:raw_message][:data].to_s
          raw.gsub!("\r\nHallo", "ses-message-id: #{ses_message_id}\r\n\r\nHallo")
          expect(raw).to eq sample_message.to_s
          expect(mailer_data[:source]).to eq 'envelope-sender@example.com'
          expect(mailer_data[:destinations]).to eq ['envelope-recipient@example.com']
        end

        it 'delivers with action mailer' do
          message = sample_message.deliver_now
          expect(message.header[:ses_message_id].value).to eq ses_message_id
        end
      end
    end
  end
end
