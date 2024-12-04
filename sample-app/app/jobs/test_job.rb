class TestJob < ApplicationJob
  self.queue_adapter = :sqs
  queue_as :default

  def perform(*args)
    puts "Job performed with args: #{args}"
    if args[0].is_a?(Hash) && args[0][:error]
      raise StandardError, 'Boom - error in job.'
    end
  end
end
