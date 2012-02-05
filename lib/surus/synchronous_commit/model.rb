module Surus
  module SynchronousCommit
    # synchronous_commit and synchronous_commit= are delegated to the underlying
    # connection object
    module Model
      delegate :synchronous_commit, :synchronous_commit=, :to => :connection
    end
  end
end

ActiveRecord::Base.extend Surus::SynchronousCommit::Model
