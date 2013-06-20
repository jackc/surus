module Surus
  module Hstore
    module ConnectionAdapters

      class PostgreSQLColumn < ActiveRecord::ConnectionAdapters::Column
        def simplified_type_with_hstore(field_type)
          field_type == 'hstore' ? :hstore : simplified_type_without_hstore(field_type)
        end

        alias_method_chain :simplified_type, :hstore
      end

      class PostgreSQLAdapter < ActiveRecord::ConnectionAdapters::AbstractAdapter
        def native_database_types_with_hstore
          native_database_types_without_hstore.merge({:hstore => { :name => "hstore" }})
        end

        alias_method_chain :native_database_types, :hstore
      end

      class TableDefinition
        # Adds hstore type for migrations. So you can add columns to a table like:
        #   create_table :people do |t|
        #     ...
        #     t.hstore :info
        #     ...
        #   end
        def hstore(*args)
          options = args.extract_options!
          column_names = args
          column_names.each { |name| column(name, 'hstore', options) }
        end

      end

      class Table
        # Adds hstore type for migrations. So you can add columns to a table like:
        #   change_table :people do |t|
        #     ...
        #     t.hstore :info
        #     ...
        #   end
        def hstore(*args)
          options = args.extract_options!
          column_names = args
          column_names.each { |name| column(name, 'hstore', options) }
        end

      end
    end
  end
end

ActiveRecord::ConnectionAdapters.extend Surus::Hstore::ConnectionAdapters
