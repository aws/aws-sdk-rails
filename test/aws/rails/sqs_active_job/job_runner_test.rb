require 'test_helper'

module Aws
  module Rails
    module SqsActiveJob
      class TestJob < ActiveJob::Base
        queue_as :default

        def perform(a1, a2)
        end
      end

      describe JobRunner do
        let(:body) { Aws::Json.dump(TestJob.new('a1', 'a2').serialize) }
        # message is a reserved minitest name
        let(:msg) { double(data: double(body: body)) }

        it 'parses the job class' do
          job_runner = JobRunner.new(msg)
          expect(job_runner.instance_variable_get(:@job)).to be_a TestJob
        end

        describe '#perform' do
          let(:job) { double('job') }

          it 'calls perform with the arguments' do
            test_msg = msg # ensure test job serializes before mock
            expect(TestJob).to receive(:new).and_return(job)
            expect(job).to receive(:perform).with('a1', 'a2')
            JobRunner.new(test_msg).perform
          end
        end
      end
    end
  end
end