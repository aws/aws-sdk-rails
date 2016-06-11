require 'test_helper'
require 'mail'

module Aws
  module Rails
    class MailerTest < Minitest::Test

      def setup
        @mailer = Mailer.new(stub_responses: true)
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
        resp = @mailer.deliver!(message)

        # over ride message-id by ses
        message_id = resp.context.params[:raw_message][:data].to_s.match(/Message-ID: <(.*)>/)[1]
        message_text = resp.context.params[:raw_message][:data].to_s.sub(
          message_id,
          "#{resp.message_id}@email.amazonses.com"
        )
        assert_equal message_text, message.to_s
        assert_equal resp.context.params[:destinations], message.destinations
      end

    end
  end
end
