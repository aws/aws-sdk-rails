require 'test_helper'

class TestJob < ActiveJob::Base
  self.queue_adapter = :amazon_sqs_async
  queue_as :default

  def perform(a1, a2)
  end
end

module ActiveJob
  module QueueAdapters
    describe AmazonSqsAsyncAdapter do

      let(:client) { double('Client') }
      before do
        Aws::Rails::SqsActiveJob.config.client = client
      end

      after do
        Aws::Rails::SqsActiveJob.config.client = nil
        Aws::Rails::SqsActiveJob.config.async_queue_error_handler = nil
      end

      it 'enqueues jobs without blocking' do
        expect(client).to receive(:send_message)
          .with(
            queue_url: 'https://queue-url',
            message_body: instance_of(String),
            message_attributes: instance_of(Hash)
          )
        expect(Concurrent::Promise).to receive(:execute).and_call_original

        TestJob.perform_later('test')
        sleep(0.1)
      end

      it 'calls the custom error handler when set' do
        expect(client).to receive(:send_message).and_raise("error")
        Aws::Rails::SqsActiveJob.config.async_queue_error_handler = proc { @error_handled = true }

        TestJob.perform_later('test')
        sleep(0.1)

        expect(@error_handled).to be true
      end
    end
  end
end
