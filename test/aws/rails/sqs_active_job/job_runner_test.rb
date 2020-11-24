require 'test_helper'
require_relative 'test_job'

module Aws
  module Rails
    module SqsActiveJob

      describe JobRunner do
        let(:job_data) { TestJob.new('a1', 'a2').serialize }
        let(:body) { Aws::Json.dump(job_data) }
        # message is a reserved minitest name
        let(:msg) { double(data: double(body: body)) }

        it 'parses the job data' do
          job_runner = JobRunner.new(msg)
          expect(job_runner.instance_variable_get(:@job_data)).to eq job_data
        end

        describe '#run' do
          it 'calls Base.execute with the job data' do
            expect(ActiveJob::Base).to receive(:execute).with(job_data)
            JobRunner.new(msg).run
          end
        end
      end
    end
  end
end