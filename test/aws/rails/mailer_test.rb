require 'test_helper'
require 'mail'

module Aws
  module Rails
    class MailerTest < Minitest::Test

      def setup
        @mailer = Mailer.new(
          stub_responses: {
            send_raw_email: {
              message_id: message_id
            }
          }
        )
      end

      def message_id
        '0000000000000000-1111111-2222-3333-4444-555555555555-666666'
      end

      def sample_message
        Mail.new do
          from    'sender@example.com'
          to      'recipient@example.com'
          subject 'This is a test'
          body    'Hallo'
        end
      end

      def test_settings_method
        expected = {}
        assert_equal expected, @mailer.settings
      end

      def test_deliver
        message = sample_message
        data = @mailer.deliver!(message).context.params
        body = data[:raw_message][:data].to_s
        body.gsub!("\r\nHallo", "ses-message-id: #{message_id}\r\n\r\nHallo")
        assert_equal body, message.to_s
        assert_equal data[:destinations], message.destinations
      end

    end
  end
end
