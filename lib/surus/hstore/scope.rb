module Surus
  module Hstore
    module Scope
      def hstore_has_pairs(column, hash)
        where("#{connection.quote_column_name(column)} @> ?", Serializer.new.dump(hash))
      end
      
      def hstore_has_key(column, key)
        where("#{connection.quote_column_name(column)} ? :key", :key => key)    
      end
      
      def hstore_has_all_keys(column, *keys)
        where("#{connection.quote_column_name(column)} ?& ARRAY[:keys]", :keys => keys.flatten)
      end
      
      def hstore_has_any_keys(column, *keys)
        where("#{connection.quote_column_name(column)} ?| ARRAY[:keys]", :keys => keys.flatten)
      end
    end
  end
end

ActiveRecord::Base.extend Surus::Hstore::Scope
