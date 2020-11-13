require 'test_helper'

module Aws
  module Rails
    class NotificationsInstrumentTest < Minitest::Test

      def client
        client_class = Aws::SES::Client.dup
        client_class.add_plugin(Aws::Rails::Notifications)
        client_class.new(stub_responses: true, logger: nil)
      end

      def test_adds_instrumentation_to_sdk_calls
        out = {}
        ActiveSupport::Notifications.subscribe(/aws/) do |name, start, finish, id, payload|
          out[:name] = name
          out[:payload] = payload
        end
        client.get_send_quota
        assert_equal out[:name], 'get_send_quota.SES.aws'
        assert out[:payload][:context].is_a?(Seahorse::Client::RequestContext)
      end
    end
  end
end
