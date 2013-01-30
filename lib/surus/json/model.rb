module Surus
  module JSON
    module Model
      def find_json(id)
        sql = select("row_to_json(#{quoted_table_name})")
          .where(id: id)
          .to_sql
        connection.select_value sql
      end
    end
  end
end

ActiveRecord::Base.extend Surus::JSON::Model
