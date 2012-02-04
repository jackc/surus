require 'benchmark_helper'

options = {}
optparse = OptionParser.new do |opts|
  options[:records] = 1000
  opts.on '-r NUM', '--records NUM', Integer, 'Number of records to create' do |n|
    options[:records] = n
  end
  
  options[:elements] = 10
  opts.on '-e NUM', '--elements NUM', Integer, 'Number of elements' do |n|
    options[:elements] = n
  end  
end

optparse.parse!

clean_database

num_records = options[:records]
num_elements = options[:elements]

arrays = num_records.times.map do
  num_elements.times.map { SecureRandom.hex(4) }
end

puts
puts "Writing #{num_records} records with a #{num_elements} element string array"

Benchmark.bm(8) do |x|
  x.report("Surus") do
    SurusKeyValueRecord.transaction do
      num_records.times do |i|
        SurusTextArrayRecord.create! :names => arrays[i]
      end
    end
  end    
  
  x.report("YAML") do
    YamlKeyValueRecord.transaction do
      num_records.times do |i|
        YamlArrayRecord.create! :names => arrays[i]
      end
    end
  end  
end
