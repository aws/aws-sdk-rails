class TestJob < ApplicationJob
  self.queue_adapter = :sqs
  queue_as :default

  def perform(*args)
    puts "Job performed with args: #{args}"
  end
end
