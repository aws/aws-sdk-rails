class TestAsyncJob < ApplicationJob
  self.queue_adapter = :sqs_async
  queue_as :default

  def perform(*args)
    puts "AsyncJob performed with args: #{args}"
  end
end
