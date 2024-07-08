# frozen_string_literal: true

module Aws
  module Rails
    module ActionMailbox
      # @api private
      class Engine < ::Rails::Engine
        config.action_mailbox.ses = ActiveSupport::OrderedOptions.new
        config.action_mailbox.ses.s3_client_options ||= {}

        initializer 'aws-sdk-rails.mount_engine' do |app|
          app.routes.append do
            mount Engine => '/'
          end
        end
      end
    end
  end
end
