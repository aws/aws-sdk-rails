require 'aws-record'

class TestTableConfigModel2
  include Aws::Record

  string_attr :uuid, hash_key: true
end
