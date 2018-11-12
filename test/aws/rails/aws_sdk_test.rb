require 'test_helper'
require 'mail'

module Aws
  module Rails
    class AwsSdkTest < Minitest::Test

      def setup
        @mailer = AwsSdk.new(stub_responses: true)
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
        assert_equal resp.context.params[:raw_message][:data].to_s, message.to_s
        assert_equal resp.context.params[:destinations], message.destinations
      end

    end
  end
end
