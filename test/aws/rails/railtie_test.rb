# frozen_string_literal: true

require 'test_helper'

module Aws
  # Test services namespaces
  module Service1
    Client = Aws::SES::Client.dup
  end

  module Service2
    Client = Aws::SES::Client.dup
  end

  module Rails
    describe 'Railtie' do
      it 'adds action mailer delivery method' do
        expect(ActionMailer::Base.delivery_methods[:ses]).to eq Aws::Rails::Mailer
      end

      it 'sets the Aws logger' do
        expect(Aws.config[:logger]).to eq ::Rails.logger
      end

      describe '.use_rails_encrypted_credentials' do
        let(:rails_creds) { ::Rails.application.credentials.aws }
        it 'sets aws credentials' do
          puts "Aws config: #{Aws.config}"
          puts "Rails creds: #{rails_creds}"
          expect(Aws.config[:access_key_id]).to eq rails_creds[:access_key_id]
          expect(Aws.config[:secret_access_key]).to eq rails_creds[:secret_access_key]
        end

        it 'does not load non credential keys into aws config' do
          expect(rails_creds[:non_credential_key]).not_to be_nil
          expect(Aws.config[:non_credential_key]).to be_nil
        end
      end

      describe '.instrument_sdk_operations' do
        it 'adds the Notifications plugin to sdk clients' do
          expect(Aws::Service1::Client).to receive(:add_plugin).with(Aws::Rails::Notifications)
          expect(Aws::Service2::Client).to receive(:add_plugin).with(Aws::Rails::Notifications)

          # Ensure other Clients don't get plugin added
          allow_any_instance_of(Class).to receive(:add_plugin)

          Aws::Rails.instrument_sdk_operations
        end
      end

    end
  end
end
