require 'surus'
require 'yaml'

require 'rspec'

database_config = YAML.load_file(File.expand_path("../database.yml", __FILE__))
ActiveRecord::Base.establish_connection database_config["test"]


class HstoreRecord < ActiveRecord::Base
  serialize :properties, Hstore::Serializer.new
end



RSpec.configure do |config|
  config.around do |example|
    ActiveRecord::Base.transaction do
      example.call
      raise ActiveRecord::Rollback
    end
  end
end

