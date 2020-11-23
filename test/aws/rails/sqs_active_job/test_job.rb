class TestJob < ActiveJob::Base
  queue_as :default

  def perform(a1, a2)
  end
end