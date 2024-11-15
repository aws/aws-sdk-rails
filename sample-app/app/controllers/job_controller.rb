class JobController < ApplicationController
  def queue_sqs_job
    TestJob.perform_later('a1', 'a2')
    render plain: 'Job enqueued'
  end

  def queue_sqs_async_job
    TestAsyncJob.perform_later('a1', 'a2')
    render plain: 'Job enqueued'
  end
end
