# frozen_string_literal: true

require 'aws-sdk-sns'

module Aws
  module Rails
    module ActionMailbox
      # @api private
      class SnsMessageVerifier
        class << self
          def verifier
            @verifier ||= Aws::SNS::MessageVerifier.new
          end
        end
      end
    end
  end
end
