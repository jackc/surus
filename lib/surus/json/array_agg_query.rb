module Surus
  module JSON
    class ArrayAggQuery < Query
      def to_sql
        "select array_to_json(coalesce(array_agg(row_to_json(t)), '{}')) from (#{subquery_sql}) t"
      end
    end
  end
end
