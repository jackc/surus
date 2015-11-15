module Surus
  module Hstore
    class Serializer
      def load(stringified_hash)
        return unless stringified_hash
        key_types = stringified_hash.delete '__key_types'
        key_types = YAML.load key_types if key_types
        value_types = stringified_hash.delete '__value_types'
        value_types = YAML.load value_types if value_types

        return stringified_hash unless key_types || value_types

        stringified_hash.each_with_object({}) do |key_value, hash|
          string_key, string_value = key_value
          key = typecast_or_string(key_types, string_key, string_key)
          value = typecast_or_string(value_types, string_key, string_value)
          hash[key] = value
        end
      end

      def typecast_or_string(item, string_key, string_value)
        return typecast(string_value, item[string_key]) if item && item.key?(string_key)
        string_value
      end

      def dump(hash)
        return unless hash

        hash_items = key_and_types(hash)
        # Use YAML for recording types as it is much simpler than trying to
        # handle all the special characters that could be in a key or value
        # and encoding them again to fit into one string. Let YAML handle all
        # the mess for us.
        hash_items[:hash]['__key_types'] = YAML.dump(hash_items[:key_types]) if hash_items[:key_types].present?
        hash_items[:hash]['__value_types'] = YAML.dump(hash_items[:value_types]) if hash_items[:value_types].present?

        hash_items[:hash].map do |key, value|
          "#{format_key(key)}=>#{format_value(value)}"
        end.join(', ')
      end

      def key_and_types(hash)
        key_types = {}
        value_types = {}
        stringified_hash = {}

        hash.each_with_object({}) do |key_value|
          key_string, key_type = stringify(key_value[0])
          value_string, value_type = stringify(key_value[1])
          stringified_hash[key_string] = value_string
          key_types[key_string] = key_type unless key_type == 'String'
          value_types[key_string] = value_type unless value_type == 'String'
        end

        {
          hash: stringified_hash,
          key_types: key_types,
          value_types: value_types
        }
      end

      def format_key(key)
        %("#{escape(key)}")
      end

      def format_value(value)
        value ? %("#{escape(value)}") : 'NULL'
      end

      # Escape a value for use as a key or value in an hstore
      def escape(value)
        value
          .gsub('\\', '\\\\\\')
          .gsub('"', '\\"')
      end

      # Unescape a value from a key or value in an hstore
      def unescape(value)
        value
          .gsub('\\\\', '\\')
          .gsub('\\"', '"')
      end

      TYPES_TO_STRING = [Symbol, Integer, Float, BigDecimal, Date, TrueClass, FalseClass].freeze
      # Returns an array of value as a string and value type
      def stringify(value)
        return [value, 'String'] if value.is_a?(String)
        return [value.to_s, value.class.to_s] if TYPES_TO_STRING.any? { |type| value.is_a?(type) && value.class == type }
        return [nil, 'String'] if value.nil?
        [YAML.dump(value), 'YAML']
      end

      BOOLEAN_TYPES = {
        'TrueClass' => true,
        'FalseClass' => false
      }.freeze

      def typecast(value, type)
        return value.to_sym if type == 'Symbol'
        return Integer(value) if type == 'Integer'
        return Float(value) if type == 'Float'
        return BigDecimal(value) if type == 'BigDecimal'
        return Date.parse(value) if type == 'Date'
        return BOOLEAN_TYPES[type] if BOOLEAN_TYPES.include? type
        return YAML.load(value) if type == 'YAML'
        fail ArgumentError, "Can't typecast: #{type}"
      end
    end
  end
end
