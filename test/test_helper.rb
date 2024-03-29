# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/spec'
require 'minitest/unit'
require 'rspec/mocks/minitest_integration'
require 'rspec/expectations/minitest_integration'

ENV['RAILS_ENV'] = 'test'
require_relative 'dummy/config/application'

Rails.application.initialize!

class TestMailer < ActionMailer::Base
  layout nil

  def deliverable(options = {})
    headers(options.delete(:headers))
    mail(options)
  end
end
