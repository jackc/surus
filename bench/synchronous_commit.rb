require 'benchmark_helper'

options = {}
optparse = OptionParser.new do |opts|
  options[:records] = 1000
  opts.on '-r NUM', '--records NUM', Integer, 'Number of records to create' do |n|
    options[:records] = n
  end
end

optparse.parse!
num_records = options[:records]
narrow_field_width = 8
wide_field_width = 25

print "Generating random data before test to avoid bias... "
random_string = SecureRandom.base64(num_records * 10 * wide_field_width)
puts "Done."

random_io = StringIO.new(random_string)

create_wide_record = lambda do
  WideRecord.create! :a => random_io.read(wide_field_width),
    :b => random_io.read(wide_field_width),
    :c => random_io.read(wide_field_width),
    :d => random_io.read(wide_field_width),
    :e => random_io.read(wide_field_width),
    :f => random_io.read(wide_field_width),
    :g => random_io.read(wide_field_width),
    :h => random_io.read(wide_field_width),
    :i => random_io.read(wide_field_width),
    :j => random_io.read(wide_field_width)
end

create_narrow_record = lambda do
  NarrowRecord.create! :a => random_io.read(narrow_field_width),
    :b => random_io.read(narrow_field_width),
    :c => random_io.read(narrow_field_width)
end

{ "narrow" => create_narrow_record, "wide" => create_wide_record }.each do |text, create_record|
  puts
  puts "Writing #{num_records} #{text} records"

  Benchmark.bm(30) do |x|
    clean_database
    random_io.rewind
    WideRecord.synchronous_commit true
    x.report("enabled") do
      num_records.times { create_record.call }
    end 

    clean_database
    random_io.rewind
    WideRecord.synchronous_commit false
    x.report("disabled") do
      num_records.times { create_record.call }
    end   
    
    clean_database
    random_io.rewind
    WideRecord.synchronous_commit true
    x.report("disabled per transaction") do
      num_records.times do
        WideRecord.transaction do
          WideRecord.synchronous_commit false
          create_record.call
        end
      end
    end
    
    clean_database
    random_io.rewind
    WideRecord.synchronous_commit true
    x.report("enabled / single transaction") do
      WideRecord.transaction do
        num_records.times { create_record.call }
      end
    end   
    
    clean_database
    random_io.rewind
    WideRecord.synchronous_commit false
    x.report("disabled / single transaction") do
      WideRecord.transaction do
        num_records.times { create_record.call }
      end
    end  
  end
end
