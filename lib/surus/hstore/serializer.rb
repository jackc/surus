module Surus
  module Hstore
    class Serializer
      def load(stringified_hash)
        return unless stringified_hash

        key_types = stringified_hash.delete "__key_types"
        key_types = YAML.load key_types if key_types
        value_types = stringified_hash.delete "__value_types"
        value_types = YAML.load value_types if value_types

        return stringified_hash unless key_types || value_types

        stringified_hash.each_with_object({}) do |key_value, hash|
          string_key, string_value = key_value

          key = if key_types && key_types.key?(string_key)
            typecast(string_key, key_types[string_key])
          else
            string_key
          end

          value = if value_types && value_types.key?(string_key)
            typecast(string_value, value_types[string_key])
          else
            string_value
          end

          hash[key] = value
        end
      end

      def dump(hash)
        return unless hash

        key_types = {}
        value_types = {}

        stringified_hash = hash.each_with_object({}) do |key_value, stringified_hash|
          key_string, key_type = stringify(key_value[0])
          value_string, value_type = stringify(key_value[1])

          stringified_hash[key_string] = value_string

          key_types[key_string] = key_type unless key_type == "String"
          value_types[key_string] = value_type unless value_type == "String"
        end

        # Use YAML for recording types as it is much simpler than trying to
        # handle all the special characters that could be in a key or value
        # and encoding them again to fit into one string. Let YAML handle all
        # the mess for us.
        stringified_hash["__key_types"] = YAML.dump(key_types) if key_types.present?
        stringified_hash["__value_types"] = YAML.dump(value_types) if value_types.present?

        stringified_hash.map do |key, value|
          "#{format_key(key)}=>#{format_value(value)}"
        end.join(", ")
      end

      def format_key(key)
        %Q("#{escape(key)}")
      end

      def format_value(value)
        value ? %Q("#{escape(value)}") : "NULL"
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

      # Returns an array of value as a string and value type
      def stringify(value)
        if value.kind_of?(String)
          [value, "String"]
        elsif value.kind_of?(Symbol)
          [value.to_s, "Symbol"]
        elsif value.kind_of?(Integer)
          [value.to_s, "Integer"]
        elsif value.kind_of?(Float)
          [value.to_s, "Float"]
        elsif value.kind_of?(BigDecimal)
          [value.to_s, "BigDecimal"]
        elsif value.kind_of?(Date)
          [value.to_s(:db), "Date"]
        elsif value.kind_of?(TrueClass)
          [value.to_s, "TrueClass"]
        elsif value.kind_of?(FalseClass)
          [value.to_s, "FalseClass"]
        elsif value == nil
          [nil, "String"] # we don't actually stringify nil because format_value special cases nil
        else
          [YAML.dump(value), "YAML"]
        end
      end

      def typecast(value, type)
        case type
        when "Symbol"
          value.to_sym
        when "Integer"
          Integer(value)
        when "Float"
          Float(value)
        when "BigDecimal"
          BigDecimal(value)
        when "Date"
          Date.parse(value)
        when "TrueClass"
          true
        when "FalseClass"
          false
        when "YAML"
          YAML.load(value)
        else
          raise ArgumentError, "Can't typecast: #{type}"
        end
      end
    end
  end
end
