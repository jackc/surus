load 'spec/spec_helper.rb'
load 'lib/generators/surus/hstore/templates/install_hstore.rb'

describe InstallHstore do
  describe 'up' do
    it 'should call be able to run on already existing hstore' do
      InstallHstore.up
    end

    it 'should be able to fetch default sql' do
      expect(InstallHstore.default_sql).to eq(File.read('./lib/generators/surus/hstore/templates/install_hstore.sql'))
    end
  end
end
