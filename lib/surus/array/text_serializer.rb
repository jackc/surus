module Surus
  module Array
    class TextSerializer
      ARRAY_REGEX = %r{
        [{,]                 (?# All elements are prefixed with either the opening brace or a comma)
        (?:
          "
          (?<quoted_string>(?:[^"\\]|\\.)*)
          "
          |
          (?<null>NULL)
          |
          (?<unquoted_string>[^,}]+)
        )
      }x

      def load(string)
        return unless string
        string.scan(ARRAY_REGEX).map do |quoted_string, null, unquoted_string|
          element = quoted_string || unquoted_string
          element ? unescape(element) : nil
        end
      end
      
      def dump(array)
        return unless array
        '{' + array.map { |s| format(s) }.join(",") + '}'
      end
      
      def format(value)
        value == nil ? "NULL" : '"' + escape(value) + '"'
      end
      
      def escape(value)
        value
          .gsub('\\', '\\\\\\')
          .gsub('"', '\\"')
      end

      def unescape(value)
        value
          .gsub('\\\\', '\\')
          .gsub('\\"', '"')
      end      
    end
  end  
end
