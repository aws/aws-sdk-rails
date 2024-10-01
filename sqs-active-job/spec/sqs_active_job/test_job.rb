# frozen_string_literal: true

class TestJob < ActiveJob::Base
  self.queue_adapter = :sqs
  queue_as :default

  def perform(arg1, arg2); end
end

class TestJobWithMessageGroupID < TestJob
  def message_group_id; end
end

class TestJobWithDedupKeys < TestJob
  include Aws::Rails::SqsActiveJob
end
