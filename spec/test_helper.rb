# frozen_string_literal: true

ENV['RAILS_ENV'] = 'test'

require_relative 'dummy/config/application'
require 'rspec/rails'

Rails.application.initialize!

class TestMailer < ActionMailer::Base
  layout nil

  def deliverable(options = {})
    headers(options.delete(:headers))
    mail(options)
  end
end
