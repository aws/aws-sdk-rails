# frozen_string_literal: true

module AwsRecord
  module Generators
    class GeneratedAttribute
      OPTS = %w[hkey rkey persist_nil db_attr_name ddb_type default_value].freeze
      INVALID_HKEY_TYPES = %i[map_attr list_attr numeric_set_attr string_set_attr].freeze
      attr_reader :name, :type
      attr_accessor :options

      def field_type
        case @type
        when :integer_attr then :number_field
        when :date_attr then :date_select
        when :datetime_attr then :datetime_select
        when :boolean_attr then :check_box
        else :text_field
        end
      end

      class << self
        def parse(field_definition)
          name, type, opts = field_definition.split(':')
          type ||= 'string'
          if OPTS.any? { |opt| type.include? opt }
            opts = type
            type = 'string'
          end

          opts = opts.split(',') if opts
          type, opts = parse_type_and_options(name, type, opts)
          validate_opt_combs(name, type, opts)

          new(name, type, opts)
        end

        private

        def validate_opt_combs(name, type, opts)
          return unless opts

          is_hkey = opts.key?(:hash_key)
          is_rkey = opts.key?(:range_key)

          if is_hkey && is_rkey
            raise ArgumentError,
                  "Field #{name} cannot be a range key and hash key simultaneously"
          end
          return unless is_hkey && INVALID_HKEY_TYPES.include?(type)

          raise ArgumentError,
                "Field #{name} cannot be a hash key and be of type #{type}"
        end

        def parse_type_and_options(name, type, opts)
          opts ||= []
          [parse_type(name, type), opts.to_h { |opt| parse_option(name, opt) }]
        end

        def parse_option(name, opt)
          case opt

          when 'hkey'
            [:hash_key, true]
          when 'rkey'
            [:range_key, true]
          when 'persist_nil'
            [:persist_nil, true]
          when /db_attr_name\{(\w+)\}/
            [:database_attribute_name, "\"#{::Regexp.last_match(1)}\""]
          when /ddb_type\{(S|N|B|BOOL|SS|NS|BS|M|L)\}/i
            [:dynamodb_type, "\"#{::Regexp.last_match(1).upcase}\""]
          when /default_value\{(.+)\}/
            [:default_value, ::Regexp.last_match(1)]
          else
            raise ArgumentError, "You provided an invalid option for #{name}: #{opt}"
          end
        end

        def parse_type(name, type)
          case type.downcase

          when 'bool', 'boolean'
            :boolean_attr
          when 'date'
            :date_attr
          when 'datetime'
            :datetime_attr
          when 'float'
            :float_attr
          when 'int', 'integer'
            :integer_attr
          when 'list'
            :list_attr
          when 'map'
            :map_attr
          when 'num_set', 'numeric_set', 'nset'
            :numeric_set_attr
          when 'string_set', 's_set', 'sset'
            :string_set_attr
          when 'string'
            :string_attr
          else
            raise ArgumentError, "Invalid type for #{name}: #{type}"
          end
        end
      end

      def initialize(name, type = :string_attr, options = {})
        @name = name
        @type = type
        @options = options
        @digest = options.delete(:digest)
      end

      # Methods used by rails scaffolding
      def password_digest?
        @digest
      end

      def polymorphic?
        false
      end

      def column_name
        if @name == 'password_digest'
          'password'
        else
          @name
        end
      end

      def human_name
        name.humanize
      end
    end
  end
end
