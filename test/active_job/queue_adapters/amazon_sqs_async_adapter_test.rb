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

      def mock_send_message
        expect(client).to receive(:send_message).with(
          {
            queue_url: 'https://queue-url',
            message_body: instance_of(String),
            message_attributes: instance_of(Hash)
          }
        )
      end

      def mock_async
        expect(Concurrent::Promises).to receive(:future).and_call_original
      end

      it 'enqueues jobs without blocking' do
        mock_send_message
        mock_async

        TestJob.perform_later('test')
        sleep(0.2)
      end

      it 'calls the custom error handler when set' do
        expect(client).to receive(:send_message).and_raise("error")
        allow(Aws::Rails::SqsActiveJob.config)
          .to receive(:async_queue_error_handler)
          .and_return(proc { @error_handled = true })

        TestJob.perform_later('test')
        sleep(0.2)

        expect(@error_handled).to be true
      end

      it 'passes the I18n locale to promises' do
        mock_send_message
        mock_async
        expect(I18n).to receive(:with_locale)
          .with(I18n.locale).and_call_original

        TestJob.perform_later('test')
        sleep(0.2)
      end

      it 'does not pass I18n locale if not defined' do
        mock_send_message
        mock_async
        # I18n comes in Rails by default - but remove it for the test
        expect_any_instance_of(AmazonSqsAsyncAdapter)
          .to receive(:i18n_locale).and_return(nil)
        expect(I18n).not_to receive(:with_locale)

        TestJob.perform_later('test')
        sleep(0.2)
      end

      it 'queues jobs to fifo queues synchronously' do
        allow(Aws::Rails::SqsActiveJob.config).to receive(:queue_url_for)
          .and_return('https://queue-url.fifo')
        expect(Concurrent::Promises).not_to receive(:future)
        expect(client).to receive(:send_message)

        TestJob.perform_later('test')
        sleep(0.2)
      end
    end
  end
end
