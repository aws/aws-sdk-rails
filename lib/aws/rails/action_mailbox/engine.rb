# frozen_string_literal: true

module Aws
  module Rails
    module ActionMailbox
      # @api private
      class Engine < ::Rails::Engine
        initializer 'aws-sdk-rails.mount_engine' do |app|
          app.config.action_mailbox.ses = ActiveSupport::OrderedOptions.new
          app.config.action_mailbox.ses.s3_client_options ||= {}

          app.routes.append do
            mount Engine => '/'
          end
        end
      end
    end
  end
end
