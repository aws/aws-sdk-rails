require 'aws-record'

class TestModelGsiBasic
  include Aws::Record

  string_attr :uuid, hash_key: true
  string_attr :gsi_hkey

  global_secondary_index(
    :SecondaryIndex,
    hash_key: :gsi_hkey,
    projection: {
      projection_type: "ALL"
    }
  )
end
