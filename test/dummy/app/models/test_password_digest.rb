# frozen_string_literal: true

require 'aws-record'

class TestPasswordDigest
  include Aws::Record
  include ActiveModel::SecurePassword

  string_attr :uuid, hash_key: true
  string_attr :password_digest
  has_secure_password
end
