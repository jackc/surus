module Surus
  module JSON
    module ConnectionAdapters

      class PostgreSQLColumn < ActiveRecord::ConnectionAdapters::Column
        def simplified_type_with_json(field_type)
          field_type == 'json' ? :json : simplified_type_without_json(field_type)
        end

        alias_method_chain :simplified_type, :json
      end

      class PostgreSQLAdapter < ActiveRecord::ConnectionAdapters::AbstractAdapter
        def native_database_types_with_json
          native_database_types_without_json.merge({:json => { :name => "json" }})
        end

        alias_method_chain :native_database_types, :json
      end

      class TableDefinition
        # Adds json type for migrations. So you can add columns to a table like:
        #   create_table :people do |t|
        #     ...
        #     t.json :info
        #     ...
        #   end
        def json(*args)
          options = args.extract_options!
          column_names = args
          column_names.each { |name| column(name, 'json', options) }
        end

      end

      class Table
        # Adds json type for migrations. So you can add columns to a table like:
        #   change_table :people do |t|
        #     ...
        #     t.json :info
        #     ...
        #   end
        def json(*args)
          options = args.extract_options!
          column_names = args
          column_names.each { |name| column(name, 'json', options) }
        end

      end
    end
  end
end

ActiveRecord::ConnectionAdapters.extend Surus::JSON::ConnectionAdapters