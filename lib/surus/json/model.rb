module Surus
  module JSON
    class Query
      attr_reader :original_scope
      attr_reader :options

      def initialize(original_scope, options={})
        @original_scope = original_scope
        @options = options
      end

      private
      def klass
        original_scope.klass
      end

      def subquery_sql
        select(columns.map(&:to_s).join(', ')).to_sql
      end

      def columns
        selected_columns + association_columns
      end

      def table_columns
        klass.columns
      end

      def selected_columns
        if options.key? :columns
          options[:columns]
        else
          table_columns.map(&:name)
        end
      end

      def association_columns
        included_associations_name_and_options.map do |association_name, association_options|
          association = klass.reflect_on_association association_name
          subquery = case association.source_macro
          when :belongs_to
            association_scope = association
              .klass
              .where("#{connection.quote_column_name association.active_record_primary_key}=#{connection.quote_column_name association.foreign_key}")
            RowQuery.new(association_scope, association_options).to_sql
          when :has_many
            association_scope = association
              .klass
              .where("#{quoted_table_name}.#{connection.quote_column_name association.active_record_primary_key}=#{connection.quote_column_name association.foreign_key}")
            ArrayAggQuery.new(association_scope, association_options).to_sql
          end
          "(#{subquery}) #{association_name}"
        end
      end

      def included_associations_name_and_options
        _include = options[:include]
        if _include.nil?
          {}
        elsif _include.kind_of?(::Hash)
          _include
        elsif _include.kind_of?(::Array)
          _include.each_with_object({}) do |e, hash|
            if e.kind_of?(Hash)
              hash.merge!(e)
            else
              hash[e] = {}
            end
          end
        else
          {_include => {}}
        end
      end

      delegate :connection, :quoted_table_name, to: :klass
      delegate :select, to: :original_scope
    end

    class RowQuery < Query
      def to_sql
        "select row_to_json(t) from (#{subquery_sql}) t"
      end
    end

    class ArrayAggQuery < Query
      def to_sql
        "select array_to_json(array_agg(row_to_json(t))) from (#{subquery_sql}) t"
      end
    end


    module Model
      def find_json(id, options={})
        sql = RowQuery.new(where(id: id), options).to_sql
        connection.select_value sql
      end
    end
  end
end

ActiveRecord::Base.extend Surus::JSON::Model
