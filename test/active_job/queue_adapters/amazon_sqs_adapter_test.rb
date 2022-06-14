require 'test_helper'
require_relative '../../aws/rails/sqs_active_job/test_job'

module ActiveJob
  module QueueAdapters
    describe AmazonSqsAdapter do

      let(:client) { double('Client') }
      before do
        allow(Aws::Rails::SqsActiveJob.config).to receive(:client).and_return(client)
      end

      it 'enqueues jobs' do
        expect(client).to receive(:send_message)
          .with(
            {
              queue_url: 'https://queue-url',
              message_body: instance_of(String),
              message_attributes: instance_of(Hash)
            }
          )
        TestJob.perform_later('test')
        sleep(0.1)
      end

      it 'adds message_deduplication_id and message_group_id to fifo queues' do
        allow(Aws::Rails::SqsActiveJob.config).to receive(:queue_url_for).and_return('https://queue-url.fifo')
        expect(client).to receive(:send_message).with(
          {
            queue_url: 'https://queue-url.fifo',
            message_body: instance_of(String),
            message_attributes: instance_of(Hash),
            message_group_id: instance_of(String),
            message_deduplication_id: instance_of(String)
          }
        )

        TestJob.perform_later('test')
        sleep(0.1)
      end

      it 'enqueues delayed jobs' do
        t1 = Time.now
        allow(Time).to receive(:now).and_return t1

        expect(client).to receive(:send_message).with(
          {
            queue_url: 'https://queue-url',
            delay_seconds: 60,
            message_body: instance_of(String),
            message_attributes: instance_of(Hash)
          }
        )

        TestJob.set(wait: 1.minute).perform_later('test')
        sleep(0.1)
      end

      it 'raises an error when job delay is great than SQS support' do
        t1 = Time.now
        allow(Time).to receive(:now).and_return t1
        expect do
          TestJob.set(wait: 1.day).perform_later('test')
        end.to raise_error ArgumentError
      end
    end
  end
end
