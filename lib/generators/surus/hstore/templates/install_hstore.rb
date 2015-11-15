class InstallHstore < ActiveRecord::Migration
  def self.up
    execute create_extension_sql
  end

  def self.down
    version = ActiveRecord::Base.connection.send(:postgresql_version)
    execute 'DROP EXTENSION hstore' if version >= 90_100
  end

  def self.create_extension_sql
    version = ActiveRecord::Base.connection.send(:postgresql_version)
    # check for newer versions
    return 'CREATE EXTENSION IF NOT EXISTS hstore' if version >= 90_100
    return File.read(hstore_sql_path) unless hstore_sql_path.nil?
    default_sql
  end

  def self.hstore_sql_path
    pg_share_dir = (`pg_config --sharedir`).strip
    file_path = File.join(pg_share_dir, 'contrib/hstore.sql')
    File.exist?(file_path) ? file_path : nil
  rescue Errno::ENOENT # if `pg_config` fails
    nil
  end

  def self.default_sql
    File.read(File.dirname(__FILE__) + '/install_hstore.sql')
  end
end
