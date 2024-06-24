require 'aws-record'

class TestScaffoldHelpers
  include Aws::Record

  string_attr :uuid, hash_key: true
end
