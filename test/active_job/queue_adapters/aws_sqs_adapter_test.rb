require 'test_helper'

module ActiveJob
  module QueueAdapters

    class TestJob < ActiveJob::Base
      queue_as :default

      def perform(a1)

      end
    end

    describe AwsSqsAdapter do

      # the dummy/application config must have:
      # config.active_job.queue_adapter = :aws_sqs
      let(:client) { double('Client') }
      before do
        Aws::Rails::SqsActiveJob.configure do |c|
          c.client = client
        end
      end

      it 'enqueues jobs' do
        expect(client).to receive(:send_message)
          .with(
            queue_url: 'https://queue-url',
            message_body: instance_of(String),
            message_attributes: instance_of(Hash)
          )
        TestJob.perform_later('test')
      end

      it 'enqueues delayed jobs' do
        t1 = Time.now
        allow(Time).to receive(:now).and_return t1

        expect(client).to receive(:send_message)
          .with(
            queue_url: 'https://queue-url',
            delay_seconds: 60,
            message_body: instance_of(String),
            message_attributes: instance_of(Hash)
          )
        TestJob.set(wait: 1.minute).perform_later('test')
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
