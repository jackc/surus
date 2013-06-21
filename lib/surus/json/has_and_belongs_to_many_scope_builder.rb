module Surus
  module JSON
    class HasAndBelongsToManyScopeBuilder < AssociationScopeBuilder
      def scope
        s = association
          .klass
          .joins("JOIN #{join_table} ON #{join_table}.#{association_foreign_key}=#{association_table}.#{association_primary_key}")
          .where("#{outside_class.quoted_table_name}.#{association_primary_key}=#{join_table}.#{foreign_key}")
        s = s.instance_eval(&association.scope) if association.scope
        s
      end

      def join_table
        connection.quote_table_name association.join_table
      end

      def association_foreign_key
        connection.quote_column_name association.association_foreign_key
      end

      def foreign_key
        connection.quote_column_name association.foreign_key
      end

      def association_table
        connection.quote_table_name association.klass.table_name
      end

      def association_primary_key
        connection.quote_column_name association.association_primary_key
      end

    end
  end
end
