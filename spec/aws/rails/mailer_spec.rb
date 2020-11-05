# frozen_string_literal: true

require_relative '../../spec_helper'
require 'mail'

class TestMailer < ActionMailer::Base
  layout nil

  def deliverable(options = {})
    mail(
      body: options[:body],
      delivery_method: :ses,
      from: options[:from],
      subject: options[:subject],
      to: options[:to]
    )
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
          subject: 'This is a test',
          to: 'recipient@example.com'
        )
      end

      let(:ses_message_id) do
        '0000000000000000-1111111-2222-3333-4444-555555555555-666666'
      end

      before {ActionMailer::Base.add_delivery_method(:ses, Mailer, client_options) }

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
          expect(mailer_data[:destinations]).to eq sample_message.destinations
        end

        it 'delivers with action mailer' do
          message = sample_message.deliver_now
          expect(message.header[:ses_message_id].value).to eq ses_message_id
        end
      end
    end
  end
end
