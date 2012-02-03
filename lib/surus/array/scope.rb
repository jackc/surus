module Surus
  module Array
    module Scope
      def array_has(column, *values)
        where("#{connection.quote_column_name(column)} @> ARRAY[?]", values.flatten)
      end
      
      def array_has_any(column, *values)
        where("#{connection.quote_column_name(column)} && ARRAY[?]", values.flatten)    
      end
    end
  end
end

ActiveRecord::Base.extend Surus::Array::Scope
