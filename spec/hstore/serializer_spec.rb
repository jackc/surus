require 'spec_helper'

describe Surus::Hstore::Serializer do
  round_trip_examples = [
    [nil, "nil"],
    [{}, "empty hash"],
    [{"foo" => "bar"}, "single key/value pair"],
    [{"foo" => "bar", "baz" => "quz"}, "multiple key/value pairs"],
    [{"foo" => nil}, "value is nil"],
  ]

  [
    ['"', 'double quote (")'],
    ["'", "single quote (')"],
    ["\\", "backslash (\\)"],
    ["\\", "multiple backslashes (\\)"],
    ["=>", "separator (=>)"],
    [" ", "space"],
    [%q~\ / / \\ => " ' " '~, "multiple special characters"]
  ].each do |value, description|
    round_trip_examples << [{"#{value}foo" => "bar"}, "key with #{description} at beginning"]
    round_trip_examples << [{"foo#{value}foo" => "bar"}, "key with #{description} in middle"]
    round_trip_examples << [{"foo#{value}" => "bar"}, "key with #{description} at end"]
    round_trip_examples << [{value => "bar"}, "key is #{description}"]

    round_trip_examples << [{"foo" => "#{value}bar"}, "value with #{description} at beginning"]
    round_trip_examples << [{"foo" => "bar#{value}bar"}, "value with #{description} in middle"]
    round_trip_examples << [{"foo" => "bar#{value}"}, "value with #{description} at end"]
    round_trip_examples << [{"foo" => value}, "value is #{description}"]
  end

  [
    [:foo, "symbol"],
    [0, "integer 0"],
    [1, "positive integer"],
    [-1, "negative integer"],
    [1_000_000_000_000_000_000_000, "huge positive integer"],
    [-1_000_000_000_000_000_000_000, "huge negative integer"],
    [0.0, "float 0.0"],
    [-0.0, "float -0.0"],
    [1.5, "positive float"],
    [-1.5, "negative float"],
    [Float::MAX, "maximum float"],
    [Float::MIN, "minimum float"],
    [BigDecimal("0"), "BigDecimal 0"],
    [BigDecimal("1"), "positive BigDecimal"],
    [BigDecimal("-1"), "negative BigDecimal"],
    [true, "true"],
    [false, "false"],
    [Date.today, "date"],
    [{"foo" => [1,2,3], "bar" => {"baz" => 42}}, "nested hash"],
    [[1,2,3], "array"]
  ].each do |value, description|
    round_trip_examples << [{"foo" => value}, "value is #{description}"]
    round_trip_examples << [{value => "bar"}, "key is #{description}"]
    round_trip_examples << [{value => value}, "key and value are each #{description}"]
  end

  round_trip_examples.each do |value, description|
    it "round trips when #{description}" do
      r = HstoreRecord.create! :properties => value
      r.reload
      expect(r.properties).to eq(value)
    end
  end
end
