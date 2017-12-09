module Surus
  module JSON
    class HasManyThroughScopeBuilder < AssociationScopeBuilder
      def scope
        s = association
          .klass
          .joins(through_table_join)
          .where("#{through_table}.#{through_foreign_key}=#{outside_table}.#{outside_primary_key}")

        s = s.instance_eval(&association.scope) if association.scope
        s
      end

      delegate :through_reflection, to: :association

      def through_table_join
        if foreign_key == through_association_foreign_key
          join_through_table_foreign_key_on_association
        else
          join_through_table_foreign_key_on_through
        end
      end

      def join_through_table_foreign_key_on_association
        "JOIN #{through_table} ON #{through_table}.#{through_primary_key}=#{association_table}.#{foreign_key}"
      end

      def join_through_table_foreign_key_on_through
        "JOIN #{through_table} ON #{through_table}.#{foreign_key}=#{association_table}.#{association_primary_key}"
      end

      def outside_table
        quote_table_name outside_class.table_name
      end

      def outside_primary_key
        quote_column_name outside_class.primary_key
      end

      def foreign_key
        quote_column_name association.foreign_key
      end

      def through_table
        quote_table_name through_reflection.table_name
      end

      def through_primary_key
        quote_column_name through_reflection.active_record_primary_key
      end

      def through_foreign_key
        quote_column_name through_reflection.foreign_key
      end

      def through_association_foreign_key
        quote_column_name through_reflection.association_foreign_key
      end

      def association_table
        quote_table_name association.klass.table_name
      end

      def association_primary_key
        quote_column_name association.association_primary_key
      end
    end
  end
end
