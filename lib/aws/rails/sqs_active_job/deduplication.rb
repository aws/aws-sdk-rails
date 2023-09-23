# frozen_string_literal: true

module Aws
  module Rails
    module SqsActiveJob
      extend ActiveSupport::Concern
  
      included do
        class_attribute :deduplication_keys
      end
  
      module ClassMethods
        def deduplicate_with(*keys)
          self.deduplication_keys = keys.map(&:to_s)
        end
      end
    end
  end
end
