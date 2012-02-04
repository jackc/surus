module Surus
  module SynchronousCommit
    module Model
      delegate :synchronous_commit, :synchronous_commit=, :to => :connection
    end
  end
end

ActiveRecord::Base.extend Surus::SynchronousCommit::Model
