module Surus
  module JSON
    class BelongsToScopeBuilder < AssociationScopeBuilder
      def scope
        s = association
          .klass
          .where("#{quote_column_name association.active_record_primary_key}=#{quote_column_name association.foreign_key}")
        s = s.instance_eval(&association.scope) if association.scope
        s
      end
    end
  end
end
