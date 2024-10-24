# frozen_string_literal: true

require 'aws-record'
require 'active_model'

class TestRequiredValidations
  include Aws::Record
  include ActiveModel::Validations

  string_attr :uuid, hash_key: true
  string_attr :title
  string_attr :body
  validates_presence_of :title, :body
end
