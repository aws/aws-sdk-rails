# frozen_string_literal: true

require 'test_helper'

module Aws
  module Rails
    class RailtieTest < Minitest::Test
      def test_adds_action_mailer_delivery_method
        assert_equal ::Aws::Rails::Mailer,
                     ::ActionMailer::Base.delivery_methods[:aws_sdk]
      end

      def test_configures_aws_sdk_logger
        assert_equal ::Rails.logger, Aws.config[:logger]
      end
    end
  end
end
