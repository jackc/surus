require 'spec_helper'

describe Surus::Array::IntegerSerializer do
  round_trip_examples = [
    [nil, "nil"],
    [[], "empty array"],
    [[0], "single element"],
    [[1, 2], "multiple elements"],
    [[-1, -2], "negative element"],
    [[1, 2, 2, 2], "duplicated elements"],
    [[1, nil], "an element is nil"],
    [(1..10_000).to_a, "huge array"]
  ]
  
  round_trip_examples.each do |value, description|
    it "round trips when #{description}" do
      r = IntegerArrayRecord.create! :integers => value
      r.reload
      r.integers.should == value
    end    
  end
end
