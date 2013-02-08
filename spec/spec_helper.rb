require 'surus'
require 'yaml'
require 'factory_girl'
require 'faker'
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
  has_many :posts, foreign_key: :author_id
end

class Forum < ActiveRecord::Base
  has_many :posts
end

class Post < ActiveRecord::Base
  belongs_to :forum
  belongs_to :author, class_name: 'User'
end

FactoryGirl.find_definitions

RSpec.configure do |config|
  config.around do |example|
    if example.metadata[:disable_transactions]
      example.call
    else
      ActiveRecord::Base.transaction do
        begin
          example.call
        ensure
          raise ActiveRecord::Rollback
        end
      end
    end
  end

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

