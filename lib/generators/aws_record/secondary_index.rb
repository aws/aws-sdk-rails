# frozen_string_literal: true

module AwsRecord
  module Generators
    class SecondaryIndex
      PROJ_TYPES = %w[ALL KEYS_ONLY INCLUDE].freeze
      attr_reader :name, :hash_key, :range_key, :projection_type

      class << self
        def parse(key_definition)
          name, index_options = key_definition.split(':')
          index_options = index_options.split(',') if index_options
          opts = parse_raw_options(index_options)

          new(name, opts)
        end

        private

        def parse_raw_options(raw_opts)
          raw_opts ||= []
          raw_opts.to_h { |opt| get_option_value(opt) }
        end

        def get_option_value(raw_option)
          case raw_option

          when /hkey\{(\w+)\}/
            [:hash_key, ::Regexp.last_match(1)]
          when /rkey\{(\w+)\}/
            [:range_key, ::Regexp.last_match(1)]
          when /proj_type\{(\w+)\}/
            [:projection_type, ::Regexp.last_match(1)]
          else
            raise ArgumentError, "Invalid option for secondary index #{raw_option}"
          end
        end
      end

      def initialize(name, opts)
        raise ArgumentError, 'You must provide a name' unless name
        raise ArgumentError, 'You must provide a hash key' unless opts[:hash_key]

        if opts.key? :projection_type
          unless PROJ_TYPES.include? opts[:projection_type]
            raise ArgumentError, "Invalid projection type #{opts[:projection_type]}"
          end
          if opts[:projection_type] != 'ALL'
            raise NotImplementedError, 'ALL is the only projection type currently supported'
          end
        else
          opts[:projection_type] = 'ALL'
        end

        if opts[:hash_key] == opts[:range_key]
          raise ArgumentError, "#{opts[:hash_key]} cannot be both the rkey and hkey for gsi #{name}"
        end

        @name = name
        @hash_key = opts[:hash_key]
        @range_key = opts[:range_key]
        @projection_type = "\"#{opts[:projection_type]}\""
      end
    end
  end
end
