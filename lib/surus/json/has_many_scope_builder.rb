module Surus
  module JSON
    class HasManyScopeBuilder < AssociationScopeBuilder
      def scope
        s = association
          .klass
          .where("#{outside_primary_key}=#{association_foreign_key}")
        s = s.instance_eval(&association.scope) if association.scope
        s
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
