require 'spec_helper'

describe Surus::Array::TextSerializer do
  round_trip_examples = [
    [nil, "nil"],
    [[], "empty array"],
    [["foo"], "single element"],
    [["foo", "bar"], "multiple elements"],
    [["foo", "bar", "bar", "bar"], "duplicated elements"],
    [["foo bar", nil], "an element is nil"],
    [["foo bar", 'NULL'], "an element is the string 'NULL'"],
    [["foo bar", "baz"], "an element has a space"],
    [["foo,bar", "baz"], "an element has a comma (,)"],
    [["foo'bar", "baz"], "an element has a single quote (')"],
    [['foo"bar', "baz"], "an element has a double quote (\")"],
    [['foo\\bar', "baz"], "an element has a backslash (\\)"],
    [['foo{}bar', "{baz}"], "an element has a braces ({})"],
    [[%q~foo \\ / " ; ' ( ) {}bar \\'~, "bar"], "an element many special characters"],
    [("aaa".."zzz").to_a, "huge array"]
  ]
  
  round_trip_examples.each do |value, description|
    it "round trips when #{description}" do
      r = TextArrayRecord.create! :texts => value
      r.reload
      r.texts.should == value
    end    
  end
end
