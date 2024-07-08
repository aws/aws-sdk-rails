# frozen_string_literal: true

require 'aws-sdk-s3'

module Aws
  module Rails
    module ActionMailbox
      # @api private
      class S3Client
        class << self
          def client
            @client ||= build_client
          end

          private

          def build_client
            client = Aws::S3::Client.new(
              **::Rails.configuration.action_mailbox.ses.s3_client_options
            )
            client.config.user_agent_frameworks << 'aws-sdk-rails'
            client
          end
        end
      end
    end
  end
end
