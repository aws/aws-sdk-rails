# frozen_string_literal: true

require 'aws-record'

module ModelTableConfig
  def self.config
    Aws::Record::TableConfig.define do |t|
      t.model_class TestTableConfigGsiProvided

      t.read_capacity_units 5
      t.write_capacity_units 2

      t.global_secondary_index(:SecondaryIndex) do |i|
        i.read_capacity_units 50
        i.write_capacity_units 100
      end
    end
  end
end
