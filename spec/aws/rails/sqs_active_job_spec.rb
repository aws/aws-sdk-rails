# frozen_string_literal: true

require 'test_helper'

module Aws
  module Rails
    describe SqsActiveJob do
      describe '.config' do
        before { Aws::Rails::SqsActiveJob.instance_variable_set(:@config, nil) }

        it 'creates and returns configuration' do
          expect(Aws::Rails::SqsActiveJob::Configuration).to receive(:new).and_call_original
          expect(Aws::Rails::SqsActiveJob.config).to be_a Aws::Rails::SqsActiveJob::Configuration
        end

        it 'creates config only once' do
          expect(Aws::Rails::SqsActiveJob::Configuration).to receive(:new).once.and_call_original
          # call twice
          Aws::Rails::SqsActiveJob.config
          Aws::Rails::SqsActiveJob.config
        end
      end

      describe '.configure' do
        it 'allows configuration through a block' do
          Aws::Rails::SqsActiveJob.configure do |config|
            config.visibility_timeout = 360
            config.excluded_deduplication_keys = [:job_class]
          end

          expect(Aws::Rails::SqsActiveJob.config).to have_attributes(
            visibility_timeout: 360,
            excluded_deduplication_keys: contain_exactly('job_class', 'job_id')
          )
        end
      end
    end
  end
end
