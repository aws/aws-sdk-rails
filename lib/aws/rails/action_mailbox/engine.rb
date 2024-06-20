# frozen_string_literal: true

module Aws
  module Rails
    module ActionMailbox
      class Engine < ::Rails::Engine
        config.action_mailbox.amazon = ActiveSupport::OrderedOptions.new

        initializer 'aws-sdk-rails.mount_engine' do |app|
          app.routes.append do
            mount Engine => '/'
          end
        end
      end
    end
  end
end
