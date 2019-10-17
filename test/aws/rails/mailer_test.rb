# frozen_string_literal: true

require 'test_helper'
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
    class MailerTest < Minitest::Test
      def setup
        @mailer = Mailer.new(client_options)
        ActionMailer::Base.add_delivery_method(:ses, Mailer, client_options)
      end

      def client_options
        {
          stub_responses: {
            send_raw_email: {
              message_id: ses_message_id
            }
          }
        }
      end

      def ses_message_id
        '0000000000000000-1111111-2222-3333-4444-555555555555-666666'
      end

      def sample_message
        TestMailer.deliverable(
          body: 'Hallo',
          from: 'sender@example.com',
          subject: 'This is a test',
          to: 'recipient@example.com'
        )
      end

      def test_settings_method
        expected = {}
        assert_equal expected, @mailer.settings
      end

      def test_deliver
        message = sample_message
        mailer_data = @mailer.deliver!(message).context.params
        raw = mailer_data[:raw_message][:data].to_s
        raw.gsub!("\r\nHallo", "ses-message-id: #{ses_message_id}\r\n\r\nHallo")
        assert_equal raw, message.to_s
        assert_equal mailer_data[:destinations], message.destinations
      end

      def test_deliver_with_action_mailer
        message = sample_message.deliver_now
        assert_equal ses_message_id, message.header[:ses_message_id].value
      end
    end
  end
end
