class TestJob < ApplicationJob
  self.queue_adapter = :sqs
  queue_as :default

  def perform(*args)
    puts "Job performed with args: #{args}"
    sleep(5)
    puts "Job finished"
  end
end
