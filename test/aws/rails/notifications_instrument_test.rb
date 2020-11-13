require 'test_helper'

module Aws
  module Rails
    describe 'NotificationsInstrument Plugin' do
      let(:client) do
        Client = Aws::SES::Client
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
