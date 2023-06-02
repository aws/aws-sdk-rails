require 'test_helper'

module Aws
  module Rails
    module SqsActiveJob
      describe Configuration do
        let(:expected_file_opts) do
          {
            max_messages: 5,
            queues: { default: 'https://queue-url' }
          }
        end
        it 'configures defaults without runtime or YAML options' do
          allow_any_instance_of(Pathname).to receive(:exist?).and_return(false)
          cfg = Aws::Rails::SqsActiveJob::Configuration.new
          expect(cfg.to_h).to include(Aws::Rails::SqsActiveJob::Configuration::DEFAULTS)
        end

        it 'merges runtime options with default options' do
          allow_any_instance_of(Pathname).to receive(:exist?).and_return(false)
          cfg = Aws::Rails::SqsActiveJob::Configuration.new(shutdown_timeout: 360)
          expect(cfg.shutdown_timeout).to eq 360
        end

        it 'merges YAML options with default options' do
          cfg = Aws::Rails::SqsActiveJob::Configuration.new
          expected = Aws::Rails::SqsActiveJob::Configuration::DEFAULTS.merge(expected_file_opts)
          expect(cfg.to_h).to include(expected)
        end

        it 'merges runtime options with YAML options' do
          cfg = Aws::Rails::SqsActiveJob::Configuration.new(shutdown_timeout: 360)
          expected = Aws::Rails::SqsActiveJob::Configuration::DEFAULTS
            .merge(expected_file_opts)
            .merge(shutdown_timeout: 360)
          expect(cfg.to_h).to include(expected)
        end

        # For Ruby 3.1+, Psych 4 will normally raise BadAlias error
        it 'accepts YAML config with alias' do
          allow_any_instance_of(ERB).to receive(:result).and_return(<<~YAML)
common: &common
  default: 'https://queue-url'
queues:
  <<: *common
          YAML
          expect { Aws::Rails::SqsActiveJob::Configuration.new }.to_not raise_error
        end

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
            end
            expect(Aws::Rails::SqsActiveJob.config.visibility_timeout).to eq 360
          end
        end

        describe '#client' do
          it 'does not create client on initialize' do
            expect(Aws::SQS::Client).not_to receive(:new)
            Aws::Rails::SqsActiveJob::Configuration.new
          end

          it 'creates a client on #client' do
            client = Aws::SQS::Client.new(stub_responses: true)
            cfg = Aws::Rails::SqsActiveJob::Configuration.new
            expect(Aws::SQS::Client).to receive(:new).and_return(client)
            cfg.client
          end
        end

        describe '#queue_url_for' do
          let(:queue_url) { 'https://queue_url' }

          let(:cfg) do
            Aws::Rails::SqsActiveJob::Configuration.new(
              queues: { default: queue_url }
            )
          end

          it 'returns the queue url' do
            expect(cfg.queue_url_for(:default)).to eq queue_url
          end

          it 'raises an ArgumentError when the queue is not mapped' do
            expect { cfg.queue_url_for(:not_mapped) }.to raise_error(ArgumentError)
          end
        end
      end
    end
  end
end
