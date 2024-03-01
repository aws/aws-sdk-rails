class HelloJob < ApplicationJob
  queue_as :default

  class NameException < StandardError; end

  retry_on NameException

  def perform(name)
    raise NameException if name == "error"

    puts "Hello from our job: #{name}"
  end
end
