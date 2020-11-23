require 'test_helper'
require_relative 'test_job'

module Aws
  module Rails
    module SqsActiveJob

      describe JobRunner do
        let(:body) { Aws::Json.dump(TestJob.new('a1', 'a2').serialize) }
        # message is a reserved minitest name
        let(:msg) { double(data: double(body: body)) }

        it 'parses the job class' do
          job_runner = JobRunner.new(msg)
          expect(job_runner.instance_variable_get(:@job)).to be_a TestJob
        end

        describe '#run' do
          let(:job) { double('job') }

          it 'calls perform with the arguments' do
            test_msg = msg # ensure test job serializes before mock
            expect(TestJob).to receive(:new).and_return(job)
            expect(job).to receive(:perform).with('a1', 'a2')
            JobRunner.new(test_msg).run
          end
        end
      end
    end
  end
end