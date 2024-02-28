# frozen_string_literal: true

require 'test_helper'
require_relative 'test_job'

module Aws
  module Rails
    module SqsActiveJob
      describe Executor do
        let(:logger) { double(info: nil, debug: nil) }

        before do
          allow(ActiveSupport::Logger).to receive(:new).and_return(logger)
        end

        it 'merges runtime options with defaults' do
          expected = Executor::DEFAULTS.merge(max_queue: 10)
          expect(Concurrent::ThreadPoolExecutor).to receive(:new).with(expected)
          Executor.new(max_queue: 10)
        end

        describe '#execute' do
          let(:body) { Aws::Json.dump(TestJob.new('a1', 'a2').serialize) }
          # message is a reserved minitest name
          let(:msg) { double(data: double(body: body)) }
          let(:executor) { Executor.new }
          let(:runner) { double('runner', id: 'jobid', class_name: 'jobclass') }

          it 'executes the job and deletes the message' do
            expect(JobRunner).to receive(:new).and_return(runner)
            expect(runner).to receive(:run)
            expect(msg).to receive(:delete)
            executor.execute(msg)
            executor.shutdown # give the job a chance to run
          end

          it 'deletes the message on exception' do
            expect(JobRunner).to receive(:new).and_return(runner)
            expect(runner).to receive(:run).and_raise StandardError
            expect(msg).to receive(:delete)
            executor.execute(msg)
            executor.shutdown # give the job a chance to run
          end

          describe 'retry_standard_errors' do
            let(:executor) { Executor.new(retry_standard_errors: true) }

            it 'does not delete the message on exception' do
              expect(JobRunner).to receive(:new).and_return(runner)
              expect(runner).to receive(:run).and_raise StandardError
              expect(msg).not_to receive(:delete)
              executor.execute(msg)
              executor.shutdown # give the job a chance to run
            end
          end
        end

        describe '#shutdown' do
          let(:tp) { double }

          it 'calls shutdown and waits for termination' do
            expect(Concurrent::ThreadPoolExecutor).to receive(:new).and_return(tp)
            executor = Executor.new
            expect(tp).to receive(:shutdown)
            expect(tp).to receive(:wait_for_termination).with(5).and_return true
            executor.shutdown(5)
          end
        end
      end
    end
  end
end
