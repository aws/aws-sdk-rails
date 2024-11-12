# frozen_string_literal: true

class ElasticBeanstalkPeriodicTask < ApplicationJob
  queue_as :default

  def perform(); end
end
