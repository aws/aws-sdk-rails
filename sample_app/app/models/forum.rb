require 'aws-record'

class Forum
  include Aws::Record

  string_attr :uuid, hash_key: true
end
