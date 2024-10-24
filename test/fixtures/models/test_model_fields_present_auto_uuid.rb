# frozen_string_literal: true

require 'aws-record'

class TestModelFieldsPresentAutoUuid
  include Aws::Record

  string_attr :uuid, hash_key: true
  string_attr :name
end
