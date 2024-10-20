# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/unit'

ENV['RAILS_ENV'] = 'test'

require_relative 'dummy/config/application'

Rails.application.initialize!
