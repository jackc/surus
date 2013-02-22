module Surus
  module JSON
    class BelongsToScopeBuilder < AssociationScopeBuilder
      def scope
        association_scope = association
          .klass
          .where("#{quote_column_name association.active_record_primary_key}=#{quote_column_name association.foreign_key}")
        association_scope = association_scope.where(conditions) if conditions
        association_scope
      end
    end
  end
end
