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
end

class VarcharArrayRecord < ActiveRecord::Base
end

class User < ActiveRecord::Base
  has_many :posts, foreign_key: :author_id
  has_many :posts_with_order,
    -> { order 'posts.id desc' },
    foreign_key: :author_id,
    class_name: 'Post'
  has_many :posts_with_conditions,
    -> { where subject: 'foo' },
    foreign_key: :author_id,
    class_name: 'Post'

  # association name is reserved word in PostgreSQL
  has_many :rows, foreign_key: :author_id, class_name: 'Post', table_name: 'posts'
end

class Forum < ActiveRecord::Base
  has_many :posts
end

class Post < ActiveRecord::Base
  belongs_to :forum
  belongs_to :author, class_name: 'User'
  belongs_to :forum_with_impossible_conditions,
    -> { where '1=2' },
    foreign_key: :forum_id,
    class_name: 'Forum'
  has_and_belongs_to_many :tags
end

class Tag < ActiveRecord::Base
  has_and_belongs_to_many :posts
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

