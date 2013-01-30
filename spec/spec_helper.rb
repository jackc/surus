require 'surus'
require 'yaml'

require 'rspec'

database_config = YAML.load_file(File.expand_path("../database.yml", __FILE__))
ActiveRecord::Base.establish_connection database_config["test"]



class HstoreRecord < ActiveRecord::Base
  serialize :properties, Surus::Hstore::Serializer.new
end

class TextArrayRecord < ActiveRecord::Base
  serialize :texts, Surus::Array::TextSerializer.new
end

class IntegerArrayRecord < ActiveRecord::Base
  serialize :integers, Surus::Array::IntegerSerializer.new
end

class FloatArrayRecord < ActiveRecord::Base
  serialize :floats, Surus::Array::FloatSerializer.new
end

class DecimalArrayRecord < ActiveRecord::Base
  serialize :decimals, Surus::Array::DecimalSerializer.new
end

class User < ActiveRecord::Base
  has_many :posts
end

class Post < ActiveRecord::Base
  belongs_to :user
end

RSpec.configure do |config|
  config.around :disable_transactions => nil do |example|
    ActiveRecord::Base.transaction do
      example.call
      raise ActiveRecord::Rollback
    end
  end

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

