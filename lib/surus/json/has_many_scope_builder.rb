module Surus
  module JSON
    class HasManyScopeBuilder < AssociationScopeBuilder
      def scope
        association_scope = association
          .klass
          .where("#{outside_primary_key}=#{association_foreign_key}")
        association_scope = association_scope.where(conditions) if conditions
        association_scope = association_scope.order(order) if order
        association_scope
      end

      def outside_primary_key
        "#{outside_class.quoted_table_name}.#{connection.quote_column_name association.active_record_primary_key}"
      end

      def association_foreign_key
        "#{connection.quote_column_name association.foreign_key}"
      end
    end
  end
end
