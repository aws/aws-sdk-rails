# frozen_string_literal: true

require 'aws-record'

module ModelTableConfig
  def self.config
    Aws::Record::TableConfig.define do |t|
      t.model_class TestModelSetTableName

      t.read_capacity_units 5
      t.write_capacity_units 2
    end
  end
end
