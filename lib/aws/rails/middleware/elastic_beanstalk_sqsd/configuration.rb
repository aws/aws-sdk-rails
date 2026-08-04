# frozen_string_literal: true

module Aws
  module Rails
    module Middleware
      class ElasticBeanstalkSQSD
        # Configuration for the {ElasticBeanstalkSQSD} middleware.
        #
        # Use {ElasticBeanstalkSQSD.config} to access the singleton config
        # instance and {ElasticBeanstalkSQSD.configure} to configure in code:
        #
        #     Aws::Rails::Middleware::ElasticBeanstalkSQSD.configure do |config|
        #       config.job_class_allowlist = [SendReceiptJob, ProcessOrderJob]
        #     end
        #
        class Configuration
          # @return [Array<Class, String>, nil] Optional list of job classes
          #   permitted to be executed. When set, only classes in this list
          #   will be dispatched. When nil, any class inheriting from
          #   ActiveJob::Base is allowed. Entries may be given as Class objects
          #   or Strings; matching is by class name, so an allowlisted class is
          #   still recognized after a Zeitwerk reload replaces the class object.
          attr_accessor :job_class_allowlist
        end
      end
    end
  end
end
