# frozen_string_literal: true

require 'test_helper'

require 'rake'

module AwsRecord
  # @api private
  class MigrateRakeTest < ActiveSupport::TestCase
    before do
      Rake.application.rake_require 'tasks/aws_record/migrate'
      Rake::Task.define_task(:environment)
    end

    # Functionality for these methods are tested in aws-record.
    # For this test, just validate the task can be invoked and calls the
    # appropriate method.
    it 'has a migrate task' do
      expect(Dir).to receive(:[]).and_return([File.join(__dir__, 'test_table_config')])
      expect($stdout).to receive(:puts).with(/test_table_config.rb/)
      Rake.application.invoke_task 'aws_record:migrate'
      assert_mock ModelTableConfig.mock
    end
  end
end
