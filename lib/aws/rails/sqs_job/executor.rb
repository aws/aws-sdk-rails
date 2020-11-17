# frozen_string_literal: true

require 'aws-sdk-sqs'
require 'optparse'
require 'concurrent'
require 'concurrent-edge'

module Aws
  module Rails
    module SqsJob
      # CLI runner for polling for SQS ActiveJobs
      class Executor

        DEFAULT_EXECUTOR_OPTIONS = {
           min_threads:     0,
           max_threads:     Concurrent.processor_count,
           auto_terminate:  true,
           idletime:        60, # 1 minute
           max_queue:       2,
           fallback_policy: :caller_runs # slow down the produced thread
        }.freeze

        def initialize(options = {})
          @executor = Concurrent::ThreadPoolExecutor.new(DEFAULT_EXECUTOR_OPTIONS.merge(options))
        end

        # Push processing
        # TODO: Consider catching the exception and sleeping instead of using :caller_runs
        def push(message)
          puts "Putting message to: #{@executor}"
          @executor.post(message) do |message|
            JobWrapper.new(message).perform
            message.delete
          rescue StandardError => e
            puts "Error processing job: #{e}"
          end
        end

        def shutdown(timeout=nil)
          # TODO: This currently gives:
          # ThreadError: can't be called from trap context
          # Unless its run in a thread, which then exits before the shutdown
          # actually completes.
          # Using .join causes a FATAL, no threads left alive.
          Thread.new do
            @executor.shutdown
            @executor.wait_for_termination(timeout)
          end
        end
      end
    end
  end
end