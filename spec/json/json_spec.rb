require 'spec_helper'
require 'oj'
ActiveRecord::Base.include_root_in_json = false

describe 'json' do
  describe 'find_json' do
    context 'with only id parameter' do
      it 'is entire row as json' do
        user = User.create! name: 'jack', email: 'jack@example.com'
        expected = Oj.load user.to_json
        actual = Oj.load User.find_json(user.id)
        expect(expected).to eq(actual)
      end
    end

    context 'with columns parameter' do
      it 'is selected row columns as json' do
        user = User.create! name: 'jack', email: 'jack@example.com'
        expected = Oj.load user.to_json only: [:id, :name]
        actual = Oj.load User.find_json(user.id, columns: [:id, :name])
        expect(expected).to eq(actual)
      end
    end
  end
end
