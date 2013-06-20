require 'active_record/connection_adapters/postgresql_adapter'

ActiveRecord::ConnectionAdapters::PostgreSQLColumn.class_eval do
  def simplified_type_with_json(field_type)
    field_type == 'json' ? :json : simplified_type_without_json(field_type)
  end

  alias_method_chain :simplified_type, :json
end


ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.class_eval do
  def native_database_types_with_json
    native_database_types_without_json.merge({:json => { :name => "json" }})
  end

  alias_method_chain :native_database_types, :json
end

ActiveRecord::ConnectionAdapters::TableDefinition.class_eval do
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

ActiveRecord::ConnectionAdapters::Table.class_eval do
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
