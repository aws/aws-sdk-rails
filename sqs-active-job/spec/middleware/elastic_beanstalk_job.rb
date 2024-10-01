# frozen_string_literal: true

class ElasticBeanstalkJob < ActiveJob::Base
  queue_as :default

  def perform(); end
end
