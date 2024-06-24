require 'aws-record'

class TestModelBasic
  include Aws::Record

  string_attr :uuid, hash_key: true
end
