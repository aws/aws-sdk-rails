# frozen_string_literal: true

require 'test_helper'
require 'mail'

class TestMailer < ActionMailer::Base
  layout nil

  def deliverable(options = {})
    mail(
      body: options[:body],
      delivery_method: :sesv2,
      from: options[:from],
      subject: options[:subject],
      to: options[:to],
      cc: options[:cc],
      bcc: options[:bcc]
    )
  end
end

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

      let(:sample_message) do
        TestMailer.deliverable(
          body: 'Hallo',
          from: 'sender@example.com',
          subject: 'This is a test',
          to: 'recipient@example.com',
          cc: 'recipient_cc@example.com',
          bcc: 'recipient_bcc@example.com'
        )
      end

      let(:ses_message_id) do
        '0000000000000000-1111111-2222-3333-4444-555555555555-666666'
      end

      before do
        ActionMailer::Base.add_delivery_method(:sesv2, Sesv2Mailer, client_options)
      end

      describe '#settings' do
        it 'returns an empty hash' do
          expect(mailer.settings).to eq({})
        end
      end

      describe '#deliver!' do
        it 'delivers the message' do
          mailer_data = mailer.deliver!(sample_message).context.params
          raw = mailer_data[:content][:raw][:data].to_s
          raw.gsub!("\r\nHallo", "ses-message-id: #{ses_message_id}\r\n\r\nHallo")
          expect(raw).to eq sample_message.to_s
          expect(mailer_data.dig(:destination, :to_addresses)).to eq Array.wrap(sample_message.to)
          expect(mailer_data.dig(:destination, :cc_addresses)).to eq Array.wrap(sample_message.cc)
          expect(mailer_data.dig(:destination, :bcc_addresses)).to eq Array.wrap(sample_message.bcc)
        end

        it 'delivers with action mailer' do
          message = sample_message.deliver_now
          expect(message.header[:ses_message_id].value).to eq ses_message_id
        end
      end
    end
  end
end
