require 'active_record/connection_adapters/postgresql_adapter'

ActiveRecord::ConnectionAdapters::PostgreSQLColumn.class_eval do
  def simplified_type_with_hstore(field_type)
    field_type == 'hstore' ? :hstore : simplified_type_without_hstore(field_type)
  end

  alias_method_chain :simplified_type, :hstore
end


ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.class_eval do
  def native_database_types_with_hstore
    native_database_types_without_hstore.merge({:hstore => { :name => "hstore" }})
  end

  alias_method_chain :native_database_types, :hstore
end

ActiveRecord::ConnectionAdapters::TableDefinition.class_eval do
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

ActiveRecord::ConnectionAdapters::Table.class_eval do
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
