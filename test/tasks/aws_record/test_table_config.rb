# frozen_string_literal: true

require 'aws-record'

module ModelTableConfig
  def self.config
    mock = MiniTest::Mock.new
    mock.expect(:compatible?, false)
    mock.expect(:migrate!, nil)
    mock
  end
end
