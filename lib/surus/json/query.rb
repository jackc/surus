module Surus
  module JSON
    class Query
      attr_reader :original_scope
      attr_reader :options

      def initialize(original_scope, options = {})
        @original_scope = original_scope
        @options = options
      end

      private

      def klass
        original_scope.klass
      end

      def subquery_sql
        (scope.respond_to?(:to_sql_with_binding_params) ? scope.to_sql_with_binding_params : scope.to_sql)
      end

      def scope
        return select(columns.map(&:to_s).join(', ')) if options.key?(:columns) || options.key?(:include)
        original_scope
      end

      def columns
        selected_columns + association_columns
      end

      def table_columns
        klass.columns
      end

      def selected_columns
        return options[:columns] if options.key? :columns
        table_columns.map do |c|
          "#{quoted_table_name}.#{connection.quote_column_name c.name}"
        end
      end

      def association_columns
        included_associations_name_and_options.map do |association_name, association_options|
          association = klass.reflect_on_association association_name

          # The way to get the association type is different in Rails 4.2 vs 4.0-4.1
          type = active_record_association(association)
          built_subquery = subquery(association, type, association_options)
          "(#{built_subquery}) #{connection.quote_column_name association_name}"
        end
      end

      def subquery(association, type, association_options)
        case type
        when :belongs_to
          association_scope = BelongsToScopeBuilder.new(original_scope, association).scope
          RowQuery.new(association_scope, association_options).to_sql
        when :has_one
          association_scope = HasManyScopeBuilder.new(original_scope, association).scope
          RowQuery.new(association_scope, association_options).to_sql
        when :has_many
          association_scope = HasManyScopeBuilder.new(original_scope, association).scope
          ArrayAggQuery.new(association_scope, association_options).to_sql
        when :has_and_belongs_to_many
          association_scope = HasAndBelongsToManyScopeBuilder.new(original_scope, association).scope
          ArrayAggQuery.new(association_scope, association_options).to_sql
        end
      end

      def active_record_association(association)
        # exit with source macro if Rails 4.0-4.1
        return association.source_macro unless defined? ActiveRecord::Reflection::BelongsToReflection
        # Rails 4.2+
        RAILS_4_2_ASSOCIATIONS[association.class.to_s]
      end

      RAILS_4_2_ASSOCIATIONS = {
        'ActiveRecord::Reflection::HasOneReflection' => :has_one,
        'ActiveRecord::Reflection::BelongsToReflection' => :belongs_to,
        'ActiveRecord::Reflection::HasManyReflection' => :has_many,
        'ActiveRecord::Reflection::HasAndBelongsToManyReflection' => :has_and_belongs_to_many
      }.freeze

      def included_associations_name_and_options
        return {} if options[:include].nil?
        return options[:include] if options[:include].is_a? ::Hash
        return include_arrays(options[:include]) if options[:include].is_a? ::Array
        { options[:include] => {} }
      end

      def include_arrays(includes)
        includes.each_with_object({}) do |e, hash|
          if e.is_a? Hash
            hash.merge!(e)
          else
            hash[e] = {}
          end
        end
      end

      delegate :connection, :quoted_table_name, to: :klass
      delegate :select, to: :original_scope
    end
  end
end
