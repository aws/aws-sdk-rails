# frozen_string_literal: true

require 'rails/all'
require 'aws_sdk_rails'
require 'minitest/autorun'

ENV['RAILS_ENV'] = 'test'

require_relative 'dummy/config/application.rb'

Rails.application.initialize!
