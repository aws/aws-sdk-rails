# frozen_string_literal: true

require 'test_helper'
require 'timecop'

module ActiveJob
  module QueueAdapters
    class AmazonSqsAdapter
      describe Params do
        describe '#queue_url' do
          let(:params) { Params.new(job, nil) }
          let(:job) { TestJob.new('a1', 'a2') }

          it 'returns url of job queue' do
            expect(params.queue_url).to eq 'https://queue-url'
          end
        end

        describe '#entry' do
          let(:params) { Params.new(job, nil) }
          let(:job) { TestJob.new('a1', 'a2') }

          it 'returns hash of core attributes' do
            expect(params.entry).to include(
              {
                message_body: instance_of(String),
                message_attributes: instance_of(Hash)
              }
            )
          end

          describe 'fifo queue' do
            before do
              allow(Aws::Rails::SqsActiveJob.config).to receive(:queue_url_for).and_return('https://queue-url.fifo')
            end

            it 'includes message_group_id and message_deduplication_id' do
              expect(params.entry).to include(
                {
                  message_body: instance_of(String),
                  message_attributes: instance_of(Hash),
                  message_group_id: String,
                  message_deduplication_id: String
                }
              )
            end
          end
        end
      end
    end
  end
end
