module Surus
  module JSON
    class Query
      attr_reader :original_scope
      attr_reader :options

      def initialize(original_scope, options={})
        @original_scope = original_scope
        @options = options
      end

      def to_sql
        selected_columns = if options.key? :columns
          options[:columns].clone
        else
          table_columns.map(&:name)
        end

        included_associations = Array(options[:include])
        included_associations.each do |association_name|
          association = klass.reflect_on_association association_name
          subquery = case association.source_macro
          when :belongs_to
            association
              .klass
              .select("row_to_json(#{association.quoted_table_name})")
              .where("#{connection.quote_column_name association.active_record_primary_key}=#{connection.quote_column_name association.foreign_key}")
              .to_sql
          when :has_many
            association
              .klass
              .select("array_to_json(array_agg(row_to_json(#{association.quoted_table_name})))")
              .where("#{quoted_table_name}.#{connection.quote_column_name association.active_record_primary_key}=#{connection.quote_column_name association.foreign_key}")
              .to_sql
          end
          selected_columns << "(#{subquery}) #{association_name}"
        end

        subquery = select(selected_columns.map(&:to_s).join(', ')).to_sql
        "select row_to_json(t) from (#{subquery}) t"
      end

      private
      def klass
        original_scope.klass
      end

      def table_columns
        klass.columns
      end

      delegate :connection, :quoted_table_name, to: :klass
      delegate :select, to: :original_scope
    end


    module Model
      def find_json(id, options={})
        sql = Query.new(where(id: id), options).to_sql
        connection.select_value sql
      end
    end
  end
end

ActiveRecord::Base.extend Surus::JSON::Model
