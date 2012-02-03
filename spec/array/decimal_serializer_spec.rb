require 'spec_helper'

describe Surus::Array::DecimalSerializer do
  round_trip_examples = [
    [nil, "nil"],
    [[], "empty array"],
    [[BigDecimal("0.0")], "single element"],
    [[BigDecimal("1.0"), BigDecimal("2.0")], "multiple elements"],
    [[BigDecimal("-1.0"), BigDecimal("-2.0")], "negative element"],
    [[BigDecimal("1232493289348929843.323422349274382923")], "high magnitude element"], 
    [[BigDecimal("1.0"), BigDecimal("2.0"), BigDecimal("2.0")], "duplicated elements"],
    [[BigDecimal("1.0"), nil], "an element is nil"],
    [(10_000.times.map { |n| n * BigDecimal("1.13312") }).to_a, "huge array"]
  ]
  
  round_trip_examples.each do |value, description|
    it "round trips when #{description}" do
      r = DecimalArrayRecord.create! :decimals => value
      r.reload
      r.decimals.should == value
    end    
  end
end
