module Surus
  module JSON
    module Serializer
      def self.load(items)
        serializer.load(items)
      end

      def self.dump(items)
        serializer.dump(items)
      end

      private

      SUPPORTED_ADAPTERS = [{ lib: 'oj', klass_name: 'Oj' }].freeze

      def self.require_adapter
        SUPPORTED_ADAPTERS.each do |item|
          begin
            require item[:lib]
            return Kernel.const_get item[:klass_name]
          rescue ::LoadError
            next
          end
        end
      end

      def self.serializer
        @serializer ||= require_adapter
      end
    end
  end
end
