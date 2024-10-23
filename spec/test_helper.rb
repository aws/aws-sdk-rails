# frozen_string_literal: true

ENV['RAILS_ENV'] = 'test'

require_relative 'dummy/config/environment'
require 'webmock/rspec'
require 'rspec/rails'

ActiveRecord::Migration.maintain_test_schema!

class TestMailer < ActionMailer::Base
  layout nil

  def deliverable(options = {})
    headers(options.delete(:headers))
    mail(options)
  end
end

def fixture_for(name, type:)
  File.read(File.join('spec', 'fixtures', type.to_s, "#{name}.#{type}"))
end

RSpec.configure do |config|
  config.use_transactional_fixtures = true
end
