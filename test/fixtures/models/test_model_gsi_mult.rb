require 'aws-record'

class TestModelGsiMult
  include Aws::Record

  string_attr :uuid, hash_key: true
  string_attr :gsi_hkey
  string_attr :gsi2_hkey

  global_secondary_index(
    :SecondaryIndex,
    hash_key: :gsi_hkey,
    projection: {
      projection_type: "ALL"
    }
  )

  global_secondary_index(
    :SecondaryIndex2,
    hash_key: :gsi2_hkey,
    projection: {
      projection_type: "ALL"
    }
  )
end
