require 'spec_helper'

describe Surus::Array::Scope do
  let!(:empty) { TextArrayRecord.create! :texts => [] }

  context "array_has" do
    let!(:match) { TextArrayRecord.create! :texts => %w{a b} }
    let!(:missing_element) { TextArrayRecord.create! :texts => %w{a} }

    def self.shared_examples
      it { should include(match) }
      it { should_not include(missing_element) }
      it { should_not include(empty) }
    end

    context "with one element" do
      subject { TextArrayRecord.array_has(:texts, "b") }
      shared_examples
    end

    context "with array of elements" do
      subject { TextArrayRecord.array_has(:texts, ["a", "b"]) }
      shared_examples
    end

    context "with multiple elements" do
      subject { TextArrayRecord.array_has(:texts, "a", "b") }
      shared_examples
    end
  end

  context "array_has_any" do
    let!(:match) { TextArrayRecord.create! :texts => %w{a b} }
    let!(:missing_element) { TextArrayRecord.create! :texts => %w{a} }

    def self.shared_examples
      it { should include(match) }
      it { should_not include(missing_element) }
      it { should_not include(empty) }
    end

    context "with one element" do
      subject { TextArrayRecord.array_has_any(:texts, "b") }
      shared_examples
    end

    context "with array of elements" do
      subject { TextArrayRecord.array_has_any(:texts, ["b", "c"]) }
      shared_examples
    end

    context "with multiple elements" do
      subject { TextArrayRecord.array_has_any(:texts, "b", "c") }
      shared_examples
    end
  end

  it "casts between varchar[] and text[]" do
    record = VarcharArrayRecord.create! :varchars => %w{a b}
    expect(VarcharArrayRecord.array_has_any(:varchars, "a")).to include(record)
    expect(VarcharArrayRecord.array_has_any(:varchars, "c")).to_not include(record)
    expect(VarcharArrayRecord.array_has_any(:varchars, "b", "c")).to include(record)
    expect(VarcharArrayRecord.array_has_any(:varchars, "c")).to_not include(record)
  end
end
