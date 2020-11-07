# frozen_string_literal: true

require 'aws-sdk-core'

module Aws
  module Rails
    # @api private
    class NotificationsInstrument < Seahorse::Client::Plugin

      def add_handlers(handlers, config)
        handlers.add(Handler, step: :initialize)
      end

      class Handler < Seahorse::Client::Handler

        def call(context)
          # TODO: Should this be #{operation_name}.#{service}?
          ActiveSupport::Notifications.instrument('operation.aws_sdk', context: context) do
            @handler.call(context)
          end
        end
      end
    end
  end
end
