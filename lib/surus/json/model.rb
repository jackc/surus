module Surus
  module JSON
    module Model
      def find_json(id, options={})
        sql = RowQuery.new(where(id: id), options).to_sql
        connection.select_value sql
      end

      def all_json(options={})
        sql = ArrayAggQuery.new(all, options).to_sql
        connection.select_value sql
      end
    end
  end
end

ActiveRecord::Base.extend Surus::JSON::Model
