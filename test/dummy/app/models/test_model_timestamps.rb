# frozen_string_literal: true

require 'aws-record'

class TestModelTimestamps
  include Aws::Record

  string_attr :uuid, hash_key: true
  datetime_attr :created, default_value: Time.now
  datetime_attr :updated, default_value: Time.now
end
