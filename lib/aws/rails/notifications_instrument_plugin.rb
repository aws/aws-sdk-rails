# frozen_string_literal: true

require 'aws-sdk-core'

module Aws
  module Rails
    # @api private
    class NotificationsInstrument < Seahorse::Client::Plugin

      def add_handlers(handlers, config)
        # This plugin needs to be first
        # which means it is called first in the stack, to start recording time,
        # and returns last
        handlers.add(Handler, step: :initialize, priority: 99)
      end

      class Handler < Seahorse::Client::Handler

        def call(context)
          # context.operation_name
          event_name = "aws.#{context.config.api.metadata['serviceId']}.#{context.operation_name}"
          ActiveSupport::Notifications.instrument(event_name, context: context) do
            @handler.call(context)
          end
        end
      end
    end
  end
end
