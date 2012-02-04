require 'benchmark_helper'

options = {}
optparse = OptionParser.new do |opts|
  options[:records] = 200
  opts.on '-r NUM', '--records NUM', Integer, 'Number of records to create' do |n|
    options[:records] = n
  end
  
  options[:pairs] = 5
  opts.on '-p NUM', '--pairs NUM', Integer, 'Number of key/value pairs' do |n|
    options[:pairs] = n
  end  
end

optparse.parse!

clean_database
GC.disable

num_records = options[:records]
num_key_value_pairs = options[:pairs]

key_value_pairs = num_records.times.map do
  num_key_value_pairs.times.each_with_object({}) do |n, hash|
    hash[SecureRandom.hex(4)] = SecureRandom.hex(4)
  end
end

puts
puts "Writing #{num_records} records with #{num_key_value_pairs} string key/value pairs"

Benchmark.bm(8) do |x|
  x.report("EAV") do
    EavMasterRecord.transaction do
      num_records.times do |i|
        EavMasterRecord.create! :properties => key_value_pairs[i]
      end
    end
  end 

  x.report("Surus") do
    SurusKeyValueRecord.transaction do
      num_records.times do |i|
        SurusKeyValueRecord.create! :properties => key_value_pairs[i]
      end
    end
  end    
  
  x.report("YAML") do
    YamlKeyValueRecord.transaction do
      num_records.times do |i|
        YamlKeyValueRecord.create! :properties => key_value_pairs[i]
      end
    end
  end  
end
