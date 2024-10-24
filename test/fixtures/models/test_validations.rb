# frozen_string_literal: true

require 'aws-record'
require 'active_model'

class TestValidations
  include Aws::Record
  include ActiveModel::Validations

  string_attr :uuid, hash_key: true
  string_attr :title
  string_attr :body
  validates_presence_of :title, :body
  validates_length_of :title, within: 5..10
  validates_length_of :body, within: 100..250
end
