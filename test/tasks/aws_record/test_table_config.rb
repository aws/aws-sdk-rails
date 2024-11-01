# frozen_string_literal: true

require 'aws-record'

module ModelTableConfig
  class << self
    def config
      @mock = MiniTest::Mock.new
      @mock.expect(:compatible?, false)
      @mock.expect(:migrate!, nil)
    end

    attr_reader :mock
  end
end
