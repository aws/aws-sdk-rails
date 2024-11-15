# frozen_string_literal: true

class ElasticBeanstalkJob < ApplicationJob
  queue_as :default

  def perform(); end
end
