module Surus
  module SynchronousCommit
    module Connection
      def synchronous_commit(value=:not_passed_param)
        if value == :not_passed_param
          select_value("SHOW synchronous_commit") == "on"
        else
          self.synchronous_commit = value
        end
      end
      
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
