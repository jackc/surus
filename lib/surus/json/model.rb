module Surus
  module JSON
    module Model
      def find_json(id, options={})
        selected_columns = if options.key? :columns
          options[:columns].clone
        else
          columns.map(&:name)
        end

        included_associations = Array(options[:includes])
        included_associations.each do |association_name|
          association = reflect_on_association association_name
          subquery = association
            .klass
            .select("row_to_json(#{association.quoted_table_name})")
            .where("#{connection.quote_column_name association.active_record_primary_key}=#{connection.quote_column_name association.foreign_key}")
            .to_sql
          selected_columns << "(#{subquery}) #{association_name}"
        end

        subquery = select(selected_columns.map(&:to_s).join(', '))
          .where(id: id)
          .to_sql
        wrapped_subquery = "(#{subquery}) t"
        sql = select("row_to_json(t)").from(wrapped_subquery).to_sql
        connection.select_value sql
      end
    end
  end
end

ActiveRecord::Base.extend Surus::JSON::Model
