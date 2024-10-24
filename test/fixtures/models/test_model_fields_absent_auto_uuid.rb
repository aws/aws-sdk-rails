# frozen_string_literal: true

require 'aws-record'

class TestModelFieldsAbsentAutoUuid
  include Aws::Record

  string_attr :uuid, hash_key: true
end
