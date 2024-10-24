# frozen_string_literal: true

require 'aws-record'

module ModelTableConfig
  def self.config
    Aws::Record::TableConfig.define do |t|
      t.model_class TestTableConfigModel2

      t.read_capacity_units 20
      t.write_capacity_units 10
    end
  end
end
