module Surus
  module Array
    class DecimalSerializer
      ARRAY_REGEX = %r{
        (?<=[\{,])                 (?# All elements are prefixed with either the opening brace or a comma)
        \-?\d+\.?\d*
        |
        NULL
      }x

      def load(string)
        return unless string
        string.scan(ARRAY_REGEX).map do |match|
          match == "NULL" ? nil : BigDecimal(match)
        end
      end
      
      def dump(array)
        return unless array
        '{' + array.map { |s| format(s) }.join(",") + '}'
      end
      
      def format(value)
        value == nil ? "NULL" : value
      end
    end
  end  
end
