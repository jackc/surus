require 'spec_helper'

describe Surus::SynchronousCommit::Connection, :disable_transactions => true do
  let(:conn) { ActiveRecord::Base.connection }
  before { conn.execute "SET synchronous_commit TO ON;" }
  after { conn.execute "SET synchronous_commit TO ON;" }

  describe "synchronous_commit" do
    context "without parameter" do
      subject { conn.synchronous_commit }

      context "when synchronous_commit commit is off" do
        before { conn.execute "SET synchronous_commit TO OFF;" }
        it { should == false }
      end

      context "when synchronous_commit commit is on" do
        before { conn.execute "SET synchronous_commit TO ON;" }
        it { should == true }
      end
    end

    context "with parameter" do
      context "true" do
        before { conn.execute "SET synchronous_commit TO OFF;" }
        it "sets synchronous_commit to on" do
          conn.synchronous_commit true
          value = conn.select_value("SHOW synchronous_commit")
          expect(value).to eq("on")
        end
      end

      context "false" do
        before { conn.execute "SET synchronous_commit TO ON;" }
        it "sets synchronous_commit to off" do
          conn.synchronous_commit false
          value = conn.select_value("SHOW synchronous_commit")
          expect(value).to eq("off")
        end
      end

      context "invalid value" do
        it "raises ArgumentError" do
          expect{conn.synchronous_commit "foo"}.to raise_error(ArgumentError)
        end
      end

      context "inside transaction" do
        before { conn.execute "SET synchronous_commit TO OFF;" }

        it "only persists for duration of transaction" do
          conn.transaction do
            conn.synchronous_commit true
            value = conn.select_value("SHOW synchronous_commit")
            expect(value).to eq("on")
          end
          value = conn.select_value("SHOW synchronous_commit")
          expect(value).to eq("off")
        end
      end
    end
  end

  describe "synchronous_commit=" do
    context "true" do
      before { conn.execute "SET synchronous_commit TO OFF;" }
      it "sets synchronous_commit to on" do
        conn.synchronous_commit true
        value = conn.select_value("SHOW synchronous_commit")
        expect(value).to eq("on")
      end
    end

    context "false" do
      before { conn.execute "SET synchronous_commit TO ON;" }
      it "sets synchronous_commit to off" do
        conn.synchronous_commit false
        value = conn.select_value("SHOW synchronous_commit")
        expect(value).to eq("off")
      end
    end

    context "invalid value" do
      it "raises ArgumentError" do
        expect{conn.synchronous_commit "foo"}.to raise_error(ArgumentError)
      end
    end

    context "inside transaction" do
      before { conn.execute "SET synchronous_commit TO OFF;" }

      it "only persists for duration of transaction" do
        conn.transaction do
          conn.synchronous_commit true
          value = conn.select_value("SHOW synchronous_commit")
          expect(value).to eq("on")
        end
        value = conn.select_value("SHOW synchronous_commit")
        expect(value).to eq("off")
      end
    end
  end
end
