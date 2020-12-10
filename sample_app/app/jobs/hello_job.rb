class HelloJob < ApplicationJob
  queue_as :default

  def perform(name)
    puts "Hello from our job: #{name}"
  end
end
