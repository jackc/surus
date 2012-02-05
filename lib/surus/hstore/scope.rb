module Surus
  module Hstore
    module Scope
      # Adds a where condition that requires column to contain hash
      #
      # Example:
      #   User.hstore_has_pairs(:properties, "favorite_color" => "green")
      def hstore_has_pairs(column, hash)
        where("#{connection.quote_column_name(column)} @> ?", Serializer.new.dump(hash))
      end
      
      # Adds a where condition that requires column to contain key
      #
      # Example:
      #   User.hstore_has_key(:properties, "favorite_color")
      def hstore_has_key(column, key)
        where("#{connection.quote_column_name(column)} ? :key", :key => key)    
      end
      
      # Adds a where condition that requires column to contain all keys.
      #
      # Example:
      #    User.hstore_has_all_keys(:properties, "favorite_color", "favorite_song")
      #    User.hstore_has_all_keys(:properties, ["favorite_color", "favorite_song"])
      def hstore_has_all_keys(column, *keys)
        where("#{connection.quote_column_name(column)} ?& ARRAY[:keys]", :keys => keys.flatten)
      end
      
      # Adds a where condition that requires column to contain any keys.
      #
      # Example:
      #    User.hstore_has_any_keys(:properties, "favorite_color", "favorite_song")
      #    User.hstore_has_any_keys(:properties, ["favorite_color", "favorite_song"])
      def hstore_has_any_keys(column, *keys)
        where("#{connection.quote_column_name(column)} ?| ARRAY[:keys]", :keys => keys.flatten)
      end
    end
  end
end

ActiveRecord::Base.extend Surus::Hstore::Scope
