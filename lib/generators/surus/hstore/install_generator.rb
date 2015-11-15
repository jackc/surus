require 'rails/generators'
require 'rails/generators/migration'

module Surus
  module Hstore
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration
      source_root File.expand_path('../templates', __FILE__)

      def self.next_migration_number(dirname)
        return Time.now.utc.strftime('%Y%m%d%H%M%S') if ActiveRecord::Base.timestamped_migrations
        format('%.3d', (current_migration_number(dirname) + 1))
      end

      desc 'creates a migration to install the hstore module'
      def install
        migration_template 'install_hstore.rb', 'db/migrate/install_hstore.rb'
      end
    end
  end
end
