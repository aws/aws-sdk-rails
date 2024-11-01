# frozen_string_literal: true

require 'aws-record'

class TestModelAutoHkey
  include Aws::Record

  string_attr :uuid, hash_key: true
end
