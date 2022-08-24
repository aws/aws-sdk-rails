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
        allow(Aws::Rails::SqsActiveJob.config).to receive(:client).and_return(client)
      end

      it 'enqueues jobs without blocking' do
        expect(client).to receive(:send_message).with(
          {
            queue_url: 'https://queue-url',
            message_body: instance_of(String),
            message_attributes: instance_of(Hash)
          }
        )
        expect(Concurrent::Promises).to receive(:future).and_call_original

        TestJob.perform_later('test')
        sleep(0.1)
      end

      it 'calls the custom error handler when set' do
        expect(client).to receive(:send_message).and_raise("error")
        allow(Aws::Rails::SqsActiveJob.config)
          .to receive(:async_queue_error_handler)
          .and_return(proc { @error_handled = true })

        TestJob.perform_later('test')
        sleep(0.1)

        expect(@error_handled).to be true
      end

      it 'queues jobs to fifo queues synchronously' do
        allow(Aws::Rails::SqsActiveJob.config).to receive(:queue_url_for).and_return('https://queue-url.fifo')
        expect(Concurrent::Promises).not_to receive(:future)
        expect(client).to receive(:send_message)

        TestJob.perform_later('test')
        sleep(0.1)
      end
    end
  end
end
