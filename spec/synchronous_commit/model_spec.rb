require 'spec_helper'

describe Surus::SynchronousCommit::Model do
  let(:conn) { ActiveRecord::Base.connection }
  
  describe "synchronous_commit" do
    it "is delegated to connection" do
      conn.should_receive(:synchronous_commit)
      ActiveRecord::Base.synchronous_commit
    end
  end
  
  describe "synchronous_commit=" do
    it "is delegated to connection" do
      conn.should_receive(:synchronous_commit=)
      ActiveRecord::Base.synchronous_commit = true
    end
  end  
end
