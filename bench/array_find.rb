require 'benchmark_helper'

options = {}
optparse = OptionParser.new do |opts|
  options[:records] = 2_000
  opts.on '-r NUM', '--records NUM', Integer, 'Number of records to create' do |n|
    options[:records] = n
  end
  
  options[:elements] = 10
  opts.on '-e NUM', '--elements NUM', Integer, 'Number of elements per array' do |n|
    options[:elements] = n
  end
  
  options[:finds] = 100
  opts.on '-f NUM', '--finds NUM', Integer, 'Number of finds to perform' do |n|
    options[:finds] = n
  end   
  
  options[:yaml] = false
  opts.on '-y', '--yaml', 'Include YAML in benchmark (VERY SLOW!)' do
    options[:yaml] = true
  end
end

optparse.parse!

clean_database

num_records = options[:records]
num_elements = options[:elements]
num_finds = options[:finds]
yaml = options[:yaml]

puts "Skipping YAML test. Use -y to enable (VERY SLOW!)" unless yaml

arrays = num_records.times.map do
  num_elements.times.map { SecureRandom.hex(4) }
end

print "Creating Surus test data... "
SurusKeyValueRecord.transaction do
  num_records.times do |i|
    SurusTextArrayRecord.create! :names => arrays[i]
  end
end
puts "Done."

if yaml
  print "Creating YAML test data... "
  YamlArrayRecord.transaction do
    num_records.times do |i|
      YamlArrayRecord.create! :names => arrays[i]
    end
  end
  puts "Done."
end

puts
puts
puts "Finding all records by inclusion of a value from #{num_records} records with #{num_elements} element arrays #{num_finds} times"

values_to_find = arrays.sample(num_finds).map { |a| a.sample }

Benchmark.bm(8) do |x|
  x.report("Surus") do
    values_to_find.each do |value_to_find|
      SurusTextArrayRecord.array_has(:names, value_to_find).all
    end
  end

  if yaml
    x.report("YAML") do
      values_to_find.each do |value_to_find|
        YamlArrayRecord.all.select { |r| r.names.include?(value_to_find) }
      end
    end    
  end
end
