# frozen_string_literal: true

require 'test_helper'

require 'fileutils'
require 'generators/dynamo_db/session_store_config/session_store_config_generator'

module DynamoDb
  module Generators
    class SessionStoreConfigGeneratorTest < Rails::Generators::TestCase
      tests SessionStoreConfigGenerator
      destination File.expand_path('../../../dummy', __dir__)

      it 'generates config file' do
        FileUtils.rm_rf(Dir["#{destination_root}/config/dynamo_db_session_store.yml"])
        run_generator
        assert_file 'config/dynamo_db_session_store.yml'
      end

      it 'generates config file with environment' do
        FileUtils.rm_rf(Dir["#{destination_root}/config/dynamo_db_session_store/development.yml"])
        run_generator %w[--environment=development]
        assert_file 'config/dynamo_db_session_store/development.yml'
      end
    end
  end
end
