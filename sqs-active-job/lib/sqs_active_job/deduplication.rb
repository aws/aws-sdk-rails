# frozen_string_literal: true

module Aws
  module Rails
    # SQS ActiveJob modules
    module SqsActiveJob
      extend ActiveSupport::Concern

      included do
        class_attribute :excluded_deduplication_keys
      end

      # class methods for SQS ActiveJob.
      module ClassMethods
        def deduplicate_without(*keys)
          self.excluded_deduplication_keys = keys.map(&:to_s) | ['job_id']
        end
      end
    end
  end
end
