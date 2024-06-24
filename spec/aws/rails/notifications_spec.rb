# frozen_string_literal: true

require 'test_helper'

module Aws
  module Rails
    describe Notifications do
      let(:client) do
        Client = Aws::SES::Client
        Client.add_plugin(Aws::Rails::Notifications)
        Client.new(stub_responses: true, logger: nil)
      end

      it 'adds instrumentation on each call' do
        out = {}
        ActiveSupport::Notifications.subscribe(/aws/) do |name, _start, _finish, _id, payload|
          out[:name] = name
          out[:payload] = payload
        end
        client.send_raw_email(raw_message: { data: 'test' })
        expect(out[:name]).to eq('send_raw_email.SES.aws')
        expect(out[:payload][:context]).to be_a(Seahorse::Client::RequestContext)
      end
    end
  end
end
