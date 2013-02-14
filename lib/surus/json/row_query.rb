module Surus
  module JSON
    class RowQuery < Query
      def to_sql
        "select row_to_json(t) from (#{subquery_sql}) t"
      end
    end
  end
end
