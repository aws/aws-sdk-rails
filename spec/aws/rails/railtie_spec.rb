# frozen_string_literal: true

require_relative '../../spec_helper'

module Aws
  module Rails

    describe 'Railtie' do
      it 'adds action mailer delivery method' do
        expect(ActionMailer::Base.delivery_methods[:ses]).to eq Aws::Rails::Mailer
      end

      it 'sets the Aws logger' do
        expect(Aws.config[:logger]).to eq ::Rails.logger
      end

      context 'rails encrypted credentials' do
        let(:rails_creds) { ::Rails.application.credentials.aws }
        it 'sets aws credentials' do
          expect(Aws.config[:access_key_id]).to eq rails_creds[:access_key_id]
          expect(Aws.config[:secret_access_key]).to eq rails_creds[:secret_access_key]
        end

        it 'does not load non credential keys into aws config' do
          expect(rails_creds[:non_credential_key]).not_to be_nil
          expect(Aws.config[:non_credential_key]).to be_nil
        end
      end

    end
  end
end
