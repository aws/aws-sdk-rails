require 'aws-record'

class TestModelSetTableName
  include Aws::Record

  string_attr :uuid, hash_key: true
  set_table_name "CustomTableName"
end
