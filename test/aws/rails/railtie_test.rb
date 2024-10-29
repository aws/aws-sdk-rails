# frozen_string_literal: true

require 'test_helper'

require 'aws-sdk-core'

module Aws
  # Test service for Notifications
  # rubocop:disable Lint/EmptyClass
  module Service
    class Client < Seahorse::Client::Base; end
  end

  module NotService
    class Client; end
  end

  class Client; end
  # rubocop:enable Lint/EmptyClass

  module Rails
    describe 'Railtie' do
      it 'uses aws credentials from rails encrypted credentials' do
        rails_creds = ::Rails.application.credentials.aws
        expect(Aws.config[:access_key_id]).to eq rails_creds[:access_key_id]
        expect(Aws.config[:secret_access_key]).to eq rails_creds[:secret_access_key]
        expect(Aws.config[:session_token]).to eq rails_creds[:session_token]
        expect(Aws.config[:account_id]).to eq rails_creds[:account_id]

        expect(rails_creds[:something]).not_to be_nil
        expect(Aws.config[:something]).to be_nil
      end

      it 'adds action mailer delivery methods' do
        expect(ActionMailer::Base.delivery_methods[:ses]).to eq Aws::Rails::SesMailer
        expect(ActionMailer::Base.delivery_methods[:sesv2]).to eq Aws::Rails::Sesv2Mailer
      end

      it 'sets the Rails logger to Aws global config' do
        expect(Aws.config[:logger]).to eq ::Rails.logger
      end

      it 'sets up eager loading for sdk services' do
        expect(Aws.methods).to include(:eager_load!)
        expect(::Rails.application.config.eager_load_namespaces).to include(Aws)
      end

      describe '.instrument_sdk_operations' do
        it 'adds the Notifications plugin to sdk clients' do
          expect(Aws::Service::Client).to receive(:add_plugin).with(Aws::Rails::Notifications)
          expect(Aws::NotService::Client).not_to receive(:add_plugin)
          expect(Aws::Client).not_to receive(:add_plugin)

          Aws::Rails.instrument_sdk_operations
        end
      end

      describe '.add_sqsd_middleware' do
        after(:each) do
          ENV.delete('AWS_PROCESS_BEANSTALK_WORKER_REQUESTS')
        end

        it 'adds middleware when AWS_PROCESS_BEANSTALK_WORKER_REQUESTS is set to true' do
          ENV['AWS_PROCESS_BEANSTALK_WORKER_REQUESTS'] = 'True'
          mock_rails_app = double
          mock_middleware_stack = []

          allow(mock_rails_app).to receive_message_chain(:config, :middleware, :use) do |middleware|
            mock_middleware_stack.push(middleware)
          end
          allow(mock_rails_app).to receive_message_chain(:config, :force_ssl).and_return(false)

          Aws::Rails.add_sqsd_middleware(mock_rails_app)

          expect(mock_middleware_stack.count).to eq(1)
          expect(mock_middleware_stack[0].inspect).to eq('Aws::Rails::EbsSqsActiveJobMiddleware')
        end
        it 'does not add middleware when AWS_PROCESS_BEANSTALK_WORKER_REQUESTS is not true' do
          ENV['AWS_PROCESS_BEANSTALK_WORKER_REQUESTS'] = 'False'
          mock_rails_app = double
          mock_middleware_stack = []

          allow(mock_rails_app).to receive_message_chain(:config, :middleware, :use) do |middleware|
            mock_middleware_stack.push(middleware)
          end
          allow(mock_rails_app).to receive_message_chain(:config, :force_ssl).and_return(false)

          Aws::Rails.add_sqsd_middleware(mock_rails_app)

          expect(mock_middleware_stack.count).to eq(0)
        end

        it 'does not add middleware when AWS_PROCESS_BEANSTALK_WORKER_REQUESTS is missing' do
          mock_rails_app = double
          mock_middleware_stack = []

          allow(mock_rails_app).to receive_message_chain(:config, :middleware, :use) do |middleware|
            mock_middleware_stack.push(middleware)
          end
          allow(mock_rails_app).to receive_message_chain(:config, :force_ssl).and_return(false)

          Aws::Rails.add_sqsd_middleware(mock_rails_app)

          expect(mock_middleware_stack.count).to eq(0)
        end
      end
    end
  end
end
