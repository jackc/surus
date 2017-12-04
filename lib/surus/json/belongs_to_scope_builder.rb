module Surus
  module JSON
    class BelongsToScopeBuilder < AssociationScopeBuilder
      def scope
        s = association
          .klass
          .where("#{association_primary_key}=#{association_foreign_key}")
        s = s.instance_eval(&association.scope) if association.scope
        s
      end

      def association_primary_key
        "#{quote_table_name association.table_name}.#{quote_column_name association.active_record_primary_key}"
      end

      def association_foreign_key
        "#{quote_table_name outside_class.table_name}.#{quote_column_name association.foreign_key}"
      end
    end
  end
end
