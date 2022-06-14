class TestJob < ActiveJob::Base
  self.queue_adapter = :amazon_sqs
  queue_as :default

  def perform(a1, a2)
  end
end

class TestJobWithMessageGroupID < TestJob
  def message_group_id; end
end
