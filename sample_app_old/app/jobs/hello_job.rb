class HelloJob < ApplicationJob
  queue_as :default

  class NameException < StandardError; end

  class SkipException < StandardError; end

  retry_on NameException
  discard_on SkipException

  def perform(name)
    raise NameException if name == "error"
    raise SkipException if name == "skip"
    raise StandardError if name == "StandardError"

    puts "Hello from our job: #{name}"
  end
end
