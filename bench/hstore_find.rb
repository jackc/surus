require 'benchmark_helper'

options = {}
optparse = OptionParser.new do |opts|
  options[:records] = 2_000
  opts.on '-r NUM', '--records NUM', Integer, 'Number of records to create' do |n|
    options[:records] = n
  end

  options[:pairs] = 5
  opts.on '-p NUM', '--pairs NUM', Integer, 'Number of key/value pairs' do |n|
    options[:pairs] = n
  end

  options[:eav] = false
  opts.on '-e', '--eav', 'Include EAV in benchmark (VERY SLOW!)' do
    options[:eav] = true
  end

  options[:yaml] = false
  opts.on '-y', '--yaml', 'Include YAML in benchmark (VERY SLOW!)' do
    options[:yaml] = true
  end
end

optparse.parse!

clean_database

num_records = options[:records]
num_key_value_pairs = options[:pairs]
eav = options[:eav]
yaml = options[:yaml]

puts "Skipping EAV test. Use -e to enable (VERY SLOW!)" unless eav
puts "Skipping YAML test. Use -y to enable (VERY SLOW!)" unless yaml

key_value_pairs = num_records.times.map do
  num_key_value_pairs.times.each_with_object({}) do |n, hash|
    hash[SecureRandom.hex(2)] = SecureRandom.hex(4)
  end
end

if eav
  print "Creating EAV test data... "
  EavMasterRecord.transaction do
    num_records.times do |i|
      EavMasterRecord.create! :properties => key_value_pairs[i]
    end
  end
  puts "Done."
end

print "Creating Surus test data... "
SurusKeyValueRecord.transaction do
  num_records.times do |i|
    SurusKeyValueRecord.create! :properties => key_value_pairs[i]
  end
end
puts "Done."

if yaml
  print "Creating YAML test data... "
  YamlKeyValueRecord.transaction do
    num_records.times do |i|
      YamlKeyValueRecord.create! :properties => key_value_pairs[i]
    end
  end
  puts "Done."
end


num_finds = 200
keys_to_find = key_value_pairs.sample(num_finds).map { |h| h.keys.sample }

puts
puts "#{num_records} records with #{num_key_value_pairs} string key/value pairs"
puts "Finding all by inclusion of a key #{num_finds} times"

Benchmark.bm(8) do |x|
  if eav
    x.report("EAV") do
      keys_to_find.each do |key_to_find|
        EavMasterRecord
          .includes(:eav_detail_records)
          .where("EXISTS(SELECT 1 FROM eav_detail_records WHERE eav_master_records.id=eav_detail_records.eav_master_record_id AND key=?)", key_to_find)
          .to_a
      end
    end
  end

  x.report("Surus") do
    keys_to_find.each do |key_to_find|
      SurusKeyValueRecord.hstore_has_key(:properties, key_to_find).to_a
    end
  end

  if yaml
    x.report("YAML") do
      keys_to_find.each do |key_to_find|
        YamlKeyValueRecord.to_a.select { |r| r.properties.key?(key_to_find) }
      end
    end
  end
end
