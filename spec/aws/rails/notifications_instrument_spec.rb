require_relative '../../spec_helper'

module Aws
  # Test namespaces
  module Service1; end
  module Service2; end

  module Rails
    describe 'NotificationsInstrument' do

      let(:base_client) { Aws::SES::Client }

      describe '.instrument_sdk_operations' do
        it 'adds the plugin to each AWS Client' do
          Aws::Service1::Client = base_client.dup
          Aws::Service2::Client = base_client.dup

          expect(Aws::Service1::Client).to receive(:add_plugin).with(Aws::Rails::Notifications)
          expect(Aws::Service2::Client).to receive(:add_plugin).with(Aws::Rails::Notifications)

          # Ensure other Clients don't get plugin added
          allow_any_instance_of(Class).to receive(:add_plugin)

          Aws::Rails.instrument_sdk_operations
        end
      end

      describe 'NotificationsInstrument Plugin' do
        let(:client) do
          Client = base_client.dup
          Client.add_plugin(Aws::Rails::Notifications)
          Client.new(stub_responses: true, logger: nil)
        end

        it 'adds instrumentation on each call' do
          out = {}
          ActiveSupport::Notifications.subscribe(/aws/) do |name, start, finish, id, payload|
            out[:name] = name
            out[:payload] = payload
          end
          client.get_send_quota
          expect(out[:name]).to eq('get_send_quota.SES.aws')
          expect(out[:payload][:context]).to be_a(Seahorse::Client::RequestContext)
        end
      end
    end
  end
end
