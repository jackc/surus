require 'spec_helper'

describe Surus::Hstore::Scope do
  let!(:empty) { HstoreRecord.create! :properties => {} }

  context "hstore_has_pairs" do
    let!(:match) { HstoreRecord.create! :properties => { "a" => "1", "b" => "2", "c" => "3" } }
    let!(:missing_key) { HstoreRecord.create! :properties => { "a" => "1", "c" => "3" } }
    let!(:wrong_value) { HstoreRecord.create! :properties => { "a" => "1", "b" => "5" } }

    subject { HstoreRecord.hstore_has_pairs(:properties, "a" => "1", "b" => "2") }

    it { should include(match) }
    it { should_not include(missing_key) }
    it { should_not include(wrong_value) }
    it { should_not include(empty) }
  end

  context "hstore_has_key" do
    let!(:match) { HstoreRecord.create! :properties => { "a" => "1", "b" => "2" } }
    let!(:missing_key) { HstoreRecord.create! :properties => { "a" => "1", "c" => "3" } }

    subject { HstoreRecord.hstore_has_key(:properties, "b") }

    it { should include(match) }
    it { should_not include(missing_key) }
    it { should_not include(empty) }
  end

  context "hstore_has_all_keys" do
    let!(:match) { HstoreRecord.create! :properties => { "a" => "1", "b" => "2", "c" => "3" } }
    let!(:missing_one_key) { HstoreRecord.create! :properties => { "b" => "2", "c" => "3" } }
    let!(:missing_all_keys) { HstoreRecord.create! :properties => { "f" => "1", "g" => "2" } }

    def self.shared_examples
      it { should include(match) }
      it { should_not include(missing_one_key) }
      it { should_not include(missing_all_keys) }
      it { should_not include(empty) }
    end

    context "with array of keys" do
      subject { HstoreRecord.hstore_has_all_keys(:properties, ["a", "b"]) }
      shared_examples
    end

    context "with multiple key arguments" do
      subject { HstoreRecord.hstore_has_all_keys(:properties, "a", "b") }
      shared_examples
    end
  end

  context "hstore_has_any_key" do
    let!(:match_1) { HstoreRecord.create! :properties => { "a" => "1", "c" => "3" } }
    let!(:match_2) { HstoreRecord.create! :properties => { "b" => "2", "d" => "4" } }
    let!(:missing_all_keys) { HstoreRecord.create! :properties => { "c" => "3", "d" => "4" } }

    def self.shared_examples
      it { should include(match_1) }
      it { should include(match_2) }
      it { should_not include(missing_all_keys) }
      it { should_not include(empty) }
      it { should_not include(empty) }
    end

    context "with array of keys" do
      subject { HstoreRecord.hstore_has_any_keys(:properties, ["a", "b"]) }
      shared_examples
    end

    context "with multiple key arguments" do
      subject { HstoreRecord.hstore_has_any_keys(:properties, "a", "b") }
      shared_examples
    end
  end
end
