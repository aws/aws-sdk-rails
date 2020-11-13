# frozen_string_literal: true

require 'test_helper'
require 'rspec/mocks/minitest_integration'

module Aws
  # Test services namespaces
  module Service1
    Client = Aws::SES::Client.dup
  end

  module Service2
    Client = Aws::SES::Client.dup
  end

  module Rails
    class RailtieTest < Minitest::Test
      def test_add_action_mailer_delivery_method
        assert_equal ::Aws::Rails::Mailer,
                     ::ActionMailer::Base.delivery_methods[:ses]
      end

      def test_log_to_rails_logger
        assert_equal ::Rails.logger, Aws.config[:logger]
      end

      def test_use_rails_encrypted_credentials
        creds = ::Rails.application.credentials.aws
        assert_equal Aws.config[:access_key_id], creds[:access_key_id]
        assert_equal Aws.config[:secret_access_key], creds[:secret_access_key]

        refute_nil creds[:non_credential_key]
        assert_nil Aws.config[:non_credential_key]
      end

      def test_instrument_sdk_operations
        expect(Aws::Service1::Client).to receive(:add_plugin).with(Aws::Rails::Notifications)
        expect(Aws::Service2::Client).to receive(:add_plugin).with(Aws::Rails::Notifications)

        # Ensure other Clients don't get plugin added
        allow_any_instance_of(Class).to receive(:add_plugin)

        Aws::Rails.instrument_sdk_operations
      end
    end
  end
end
