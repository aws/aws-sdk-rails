# frozen_string_literal: true

require 'rails/generators/named_base'

module DynamoDb
  module Generators
    # Generates a config file for DynamoDB session storage.
    class SessionStoreConfigGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      # Environment to generate the config file for
      class_option :environment,
        desc: 'Optional rails environment to generate the config file for',
        type: :string,
        default: nil

      def copy_sample_config_file
        path = 'config/dynamo_db_session_store'
        path += "/#{options['environment']}" if options['environment']
        template('dynamo_db_session_store.yml', "#{path}.yml")
      end
    end
  end
end
