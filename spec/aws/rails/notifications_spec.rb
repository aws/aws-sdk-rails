# frozen_string_literal: true

module Aws
  module Rails
    describe Notifications do
      let(:client) do
        Aws::STS::Client.new(stub_responses: true)
      end

      it 'adds instrumentation on each call' do
        out = {}
        ActiveSupport::Notifications.subscribe(/aws/) do |name, _start, _finish, _id, payload|
          out[:name] = name
          out[:payload] = payload
        end
        client.get_caller_identity
        expect(out[:name]).to eq('get_caller_identity.STS.aws')
        expect(out[:payload][:context]).to be_a(Seahorse::Client::RequestContext)
      end
    end
  end
end
