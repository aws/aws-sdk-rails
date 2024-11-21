# frozen_string_literal: true

module Aws
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

      it 'sets the Rails logger to Aws global config' do
        expect(Aws.config[:logger]).to eq ::Rails.logger
      end

      it 'sets up eager loading for sdk services' do
        expect(Aws.methods).to include(:eager_load!)
        expect(::Rails.application.config.eager_load_namespaces).to include(Aws)
      end

      it 'adds the Notifications plugin to sdk clients' do
        expect(Aws::STS::Client.plugins).to include(Aws::Rails::Notifications)
        expect(Aws::NotService::Client.plugins).not_to include(Aws::Rails::Notifications)
        expect(Aws::Client.plugins).not_to include(Aws::Rails::Notifications)
      end

      context 'sqsd middleware' do
        describe 'AWS_PROCESS_BEANSTALK_WORKER_REQUESTS is set' do
          before do
            ENV['AWS_PROCESS_BEANSTALK_WORKER_REQUESTS'] = 'true'
          end

          after do
            ENV.delete('AWS_PROCESS_BEANSTALK_WORKER_REQUESTS')
          end

          it 'adds the middleware' do
            mock_rails_app = double
            mock_middleware_stack = []

            allow(mock_rails_app).to receive_message_chain(:config, :middleware, :use) do |middleware|
              mock_middleware_stack.push(middleware)
            end
            allow(mock_rails_app).to receive_message_chain(:config, :force_ssl).and_return(false)

            Aws::Rails.add_sqsd_middleware(mock_rails_app)

            expect(mock_middleware_stack.count).to eq(1)
            expect(mock_middleware_stack[0].inspect).to eq('Aws::Rails::Middleware::ElasticBeanstalkSQSD')
          end

          it 'adds the middleware before SSL when force_ssl is true' do
            mock_rails_app = double
            mock_middleware_stack = []

            allow(mock_rails_app).to receive_message_chain(:config, :middleware,
                                                           :insert_before) do |_before, middleware|
              mock_middleware_stack.push(middleware)
            end
            allow(mock_rails_app).to receive_message_chain(:config, :force_ssl).and_return(true)

            Aws::Rails.add_sqsd_middleware(mock_rails_app)

            expect(mock_middleware_stack.count).to eq(1)
            expect(mock_middleware_stack[0].inspect).to eq('Aws::Rails::Middleware::ElasticBeanstalkSQSD')
          end
        end

        describe 'AWS_PROCESS_BEANSTALK_WORKER_REQUESTS is not set' do
          it 'does not add the middleware' do
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
end
