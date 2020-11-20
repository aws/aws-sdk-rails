# frozen_string_literal: true

module Aws
  module Rails
    module SqsActiveJob

      class JobRunner
        def initialize(message)
          body = Aws::Json.load(message.data.body)
          job_class = body["job_class"].constantize
          @job = job_class.new
          @arguments = body["arguments"]
        end

        def perform
          @job.perform(*@arguments)
        end
      end
    end
  end
end
