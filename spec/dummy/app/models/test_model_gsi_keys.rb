require 'aws-record'

class TestModelGsiKeys
  include Aws::Record

  string_attr :uuid, hash_key: true
  string_attr :gsi_hkey
  string_attr :gsi_rkey

  global_secondary_index(
    :SecondaryIndex,
    hash_key: :gsi_hkey,
    range_key: :gsi_rkey,
    projection: {
      projection_type: "ALL"
    }
  )
end
