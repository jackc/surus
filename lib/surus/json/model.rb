module Surus
  module JSON
    module Model
      def find_json(id, options={})
        sql = if options.key? :columns
          columns = options[:columns]
          subquery = select(columns.map(&:to_s).join(', '))
            .where(id: id)
            .to_sql
          wrapped_subquery = "(#{subquery}) t"
          select("row_to_json(t)").from(wrapped_subquery).to_sql
        else
          select("row_to_json(#{quoted_table_name})")
            .where(id: id)
            .to_sql
        end
        connection.select_value sql
      end
    end
  end
end

ActiveRecord::Base.extend Surus::JSON::Model
