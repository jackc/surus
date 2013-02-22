module Surus
  module JSON
    class AssociationScopeBuilder
      attr_reader :outside_scope
      attr_reader :association

      def initialize(outside_scope, association)
        @outside_scope = outside_scope
        @association = association
      end

      def outside_class
        @outside_scope.klass
      end

      delegate :connection, to: :outside_class
      delegate :quote_table_name, :quote_column_name, to: :connection

      def conditions
        association.options[:conditions]
      end

      def order
        association.options[:order]
      end
    end
  end
end
