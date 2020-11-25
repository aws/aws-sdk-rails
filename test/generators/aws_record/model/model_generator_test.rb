require 'test_helper'

require 'rails/generators/test_case'
require 'generators/aws_record/model/model_generator'

module AwsRecord
  module Generators
    class ModelGeneratorTest < Rails::Generators::TestCase
      tests ModelGenerator
      destination File.expand_path('../../../dummy', __dir__)

      def test_generates_model
        run_generator ['Forum', '--table-config=primary:5-2', '-f']
        assert_file 'app/models/forum.rb'
      end

      def test_generates_table_config
        run_generator ['Forum', '--table-config=primary:5-2', '-f']
        assert_file 'db/table_config/forum_config.rb'
      end
    end
  end
end
