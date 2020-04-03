# frozen_string_literal: true

require 'test_helper'

module Aws
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
    end
  end
end
