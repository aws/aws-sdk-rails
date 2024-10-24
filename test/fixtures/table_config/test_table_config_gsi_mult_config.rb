# frozen_string_literal: true

require 'aws-record'

module ModelTableConfig
  def self.config
    Aws::Record::TableConfig.define do |t|
      t.model_class TestTableConfigGsiMult

      t.read_capacity_units 5
      t.write_capacity_units 2

      t.global_secondary_index(:SecondaryIndex) do |i|
        i.read_capacity_units 10
        i.write_capacity_units 11
      end

      t.global_secondary_index(:SecondaryIndex2) do |i|
        i.read_capacity_units 40
        i.write_capacity_units 20
      end
    end
  end
end
