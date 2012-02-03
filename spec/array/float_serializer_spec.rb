require 'spec_helper'

describe Surus::Array::FloatSerializer do
  round_trip_examples = [
    [nil, "nil"],
    [[], "empty array"],
    [[0.0], "single element"],
    [[1.0, 2.0], "multiple elements"],
    [[-1.0, -2.0], "negative element"],
    [[4.4325349e+45, 1.2324323e+77, 1.1242342e-57, 3e99], "high magnitude elements"], 
    [[1.0, 2.0, 2.0, 2.0], "duplicated elements"],
    [[1.0, nil], "an element is nil"],
    [(10_000.times.map { |n| n * 1.0 }).to_a, "huge array"]
  ]
  
  round_trip_examples.each do |value, description|
    it "round trips when #{description}" do
      r = FloatArrayRecord.create! :floats => value
      r.reload
      r.floats.should == value
    end    
  end
end
