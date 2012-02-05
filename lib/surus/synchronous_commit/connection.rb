module Surus
  module SynchronousCommit
    module Connection
      # When called without any value returns the current synchronous_commit
      # value.
      #
      # When called with a value it is delegated to #synchronous_commit=
      def synchronous_commit(value=:not_passed_param)
        if value == :not_passed_param
          select_value("SHOW synchronous_commit") == "on"
        else
          self.synchronous_commit = value
        end
      end
      
      # Changes current synchronous_commit state. If a transaction is currently
      # in progress the change will be reverted at the end of the transaction.
      #
      # Requires true or false to be passed exactly -- not merely truthy or falsy
      def synchronous_commit=(value)
        raise ArgumentError, "argument must be true or false" unless value == true || value == false
        
        execute "SET #{'LOCAL' if open_transactions > 0} synchronous_commit TO #{value ? 'ON' : 'OFF'}"
      end
    end
  end
end

# If Surus is loaded before establish_connection is called then
# PostgreSQLAdapter will not be loaded yet. require it to ensure
# it is available
require "active_record/connection_adapters/postgresql_adapter"

ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.send :include, Surus::SynchronousCommit::Connection
