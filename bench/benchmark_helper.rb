require 'surus'
require 'benchmark'
require 'securerandom'
require 'optparse'

database_config = YAML.load_file(File.expand_path("../database.yml", __FILE__))
ActiveRecord::Base.establish_connection database_config["bench"]

class YamlKeyValueRecord < ActiveRecord::Base
  serialize :properties
end

class SurusKeyValueRecord < ActiveRecord::Base
  serialize :properties, Surus::Hstore::Serializer.new
end

class EavMasterRecord < ActiveRecord::Base
  has_many :eav_detail_records
  
  def properties
    @properties ||= eav_detail_records.each_with_object({}) do |d, hash|
      hash[d.key] = d.value
    end
  end
  
  def properties=(value)
    @properties = value
  end
  
  after_save :persist_properties
  def persist_properties
    eav_detail_records.clear
    @properties.each do |k,v|
      eav_detail_records.create! :key => k, :value => v
    end
  end
end

class EavDetailRecord < ActiveRecord::Base
  belongs_to :eav_master_record
end

class YamlArrayRecord < ActiveRecord::Base
  serialize :names
end

class SurusTextArrayRecord < ActiveRecord::Base
  serialize :names, Surus::Array::TextSerializer.new
end

class WideRecord < ActiveRecord::Base
end

class NarrowRecord < ActiveRecord::Base
end

def clean_database
  YamlKeyValueRecord.delete_all
  SurusKeyValueRecord.delete_all
  EavDetailRecord.delete_all
  EavMasterRecord.delete_all
  YamlArrayRecord.delete_all
  WideRecord.delete_all
  NarrowRecord.delete_all
end
