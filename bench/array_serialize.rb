require 'benchmark_helper'

options = {}
optparse = OptionParser.new do |opts|
  options[:elements] = 10
  opts.on '-e NUM', '--elements NUM', Integer, 'Number of elements per array' do |n|
    options[:elements] = n
  end
end

optparse.parse!

clean_database

num_elements = options[:elements]
array = num_elements.times.map { SecureRandom.hex(4) }

SurusTextArrayRecord.create! :names => array
YamlArrayRecord.create! :names => array

num_reads = 3_000

puts
puts "Reading a single record with a #{num_elements} element array #{num_reads} times"

Benchmark.bm(8) do |x|
  x.report("Surus") do
    num_reads.times { SurusTextArrayRecord.first.names }
  end    
  
  x.report("YAML") do
    num_reads.times { YamlArrayRecord.first.names }
  end  
end
