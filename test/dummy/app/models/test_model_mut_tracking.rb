# frozen_string_literal: true

require 'aws-record'

class TestModelMutTracking
  include Aws::Record
  disable_mutation_tracking

  string_attr :uuid, hash_key: true
end
