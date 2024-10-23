# frozen_string_literal: true

class ElasticBeanstalkPeriodicTask < ActiveJob::Base
  queue_as :default

  def perform(); end
end
