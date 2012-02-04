require 'benchmark_helper'

options = {}
optparse = OptionParser.new do |opts|
  options[:pairs] = 5
  opts.on '-p NUM', '--pairs NUM', Integer, 'Number of key/value pairs' do |n|
    options[:pairs] = n
  end  
end

optparse.parse!

clean_database

num_key_value_pairs = options[:pairs]

key_value_pair = num_key_value_pairs.times.each_with_object({}) do |n, hash|
  hash[SecureRandom.hex(4)] = SecureRandom.hex(4)
end

EavMasterRecord.create! :properties => key_value_pair
SurusKeyValueRecord.create! :properties => key_value_pair
YamlKeyValueRecord.create! :properties => key_value_pair

num_reads = 3_000

puts
puts "Reading a single record with #{num_key_value_pairs} string key/value pairs #{num_reads} times"

Benchmark.bm(8) do |x|
  x.report("EAV") do
    num_reads.times { EavMasterRecord.first.properties }
  end 

  x.report("Surus") do
    num_reads.times { SurusKeyValueRecord.first.properties }
  end    
  
  x.report("YAML") do
    num_reads.times { YamlKeyValueRecord.first.properties }
  end  
end
