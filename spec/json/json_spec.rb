require 'spec_helper'
require 'oj'
ActiveRecord::Base.include_root_in_json = false

describe 'json' do
  describe 'find_json' do
    context 'with only id parameter' do
      it 'is entire row as json' do
        user = FactoryGirl.create :user
        to_json = Oj.load user.to_json
        find_json = Oj.load User.find_json(user.id)
        expect(find_json).to eq(to_json)
      end
    end

    context 'with columns parameter' do
      it 'is selected row columns as json' do
        user = FactoryGirl.create :user
        to_json = Oj.load user.to_json only: [:id, :name]
        find_json = Oj.load User.find_json(user.id, columns: [:id, :name])
        expect(find_json).to eq(to_json)
      end
    end

    context 'when scope chain has a joins with ambiguous column names' do
      it 'works' do
        user = FactoryGirl.create :user
        FactoryGirl.create :post, author: user
        to_json = Oj.load user.to_json
        find_json = Oj.load User.joins(:posts).find_json(user.id)
        expect(find_json).to eq(to_json)
      end
    end

    context 'with includes option' do
      it 'includes entire belongs_to object' do
        post = FactoryGirl.create :post
        to_json = Oj.load post.to_json(include: :author)
        find_json = Oj.load Post.find_json(post.id, include: :author)
        expect(find_json).to eq(to_json)
      end

      it 'filters by belongs_to conditions' do
        post = FactoryGirl.create :post
        find_json = Oj.load Post.find_json(post.id, include: :forum_with_impossible_conditions)
        expect(find_json.fetch('forum_with_impossible_conditions')).to be_nil
      end

      it 'includes multiple entire belongs_to objects' do
        post = FactoryGirl.create :post
        to_json = Oj.load post.to_json(include: [:author, :forum])
        find_json = Oj.load Post.find_json(post.id, include: [:author, :forum])
        expect(find_json).to eq(to_json)
      end

      it 'includes only selected columns of belongs_to object' do
        post = FactoryGirl.create :post
        to_json = Oj.load post.to_json(include: {author: {only: [:id, :name]}})
        find_json = Oj.load Post.find_json(post.id, include: {author: {columns: [:id, :name]}})
        expect(find_json).to eq(to_json)
      end

      it 'includes entire has_many association' do
        user = FactoryGirl.create :user
        posts = FactoryGirl.create_list :post, 2, author: user
        user.reload
        to_json = Oj.load user.to_json(include: :posts)
        find_json = Oj.load User.find_json(user.id, include: :posts)
        expect(find_json).to eq(to_json)
      end

      it 'preserves has_many order' do
        user = FactoryGirl.create :user
        posts = FactoryGirl.create_list :post, 2, author: user
        user.reload
        to_json = Oj.load user.to_json(include: :posts_with_order)
        find_json = Oj.load User.find_json(user.id, include: :posts_with_order)
        expect(find_json).to eq(to_json)
      end

      it 'filters by has_many conditions' do
        user = FactoryGirl.create :user
        FactoryGirl.create :post, author: user, subject: 'foo'
        FactoryGirl.create :post, author: user
        user.reload
        to_json = Oj.load user.to_json(include: :posts_with_conditions)
        find_json = Oj.load User.find_json(user.id, include: :posts_with_conditions)
        expect(find_json).to eq(to_json)
      end

      it 'includes only select columns of has_many association' do
        user = FactoryGirl.create :user
        posts = FactoryGirl.create_list :post, 2, author: user
        user.reload
        to_json = Oj.load user.to_json(include: {posts: {only: [:id, :subject]}})
        find_json = Oj.load User.find_json(user.id, include: {posts: {columns: [:id, :subject]}})
        expect(find_json).to eq(to_json)
      end

      it 'includes empty array for empty has_many association' do
        user = FactoryGirl.create :user
        to_json = Oj.load user.to_json(include: :posts)
        find_json = Oj.load User.find_json(user.id, include: :posts)
        expect(find_json).to eq(to_json)
      end

      it 'includes has_many association with a PostgreSQL reserved word as name' do
        user = FactoryGirl.create :user
        posts = FactoryGirl.create_list :post, 2, author: user
        user.reload
        to_json = Oj.load user.to_json(include: :rows)
        find_json = Oj.load User.find_json(user.id, include: :rows)
        expect(find_json).to eq(to_json)
      end

      it 'includes entire has_and_belongs_to_many association' do
        post = FactoryGirl.create :post
        tag = FactoryGirl.create :tag
        post.tags << tag
        to_json = Oj.load post.to_json(include: :tags)
        find_json = Oj.load Post.find_json(post.id, include: :tags)
        expect(find_json).to eq(to_json)
      end

      it 'excludes other has_and_belongs_to_many association records' do
        post = FactoryGirl.create :post
        tag = FactoryGirl.create :tag
        post.tags << tag
        other_post = FactoryGirl.create :post
        other_tag = FactoryGirl.create :tag
        other_post.tags << other_tag
        to_json = Oj.load post.to_json(include: :tags)
        find_json = Oj.load Post.find_json(post.id, include: :tags)
        expect(find_json).to eq(to_json)
      end

      it 'includes empty array for empty has_and_belongs_to_many' do
        post = FactoryGirl.create :post
        to_json = Oj.load post.to_json(include: :tags)
        find_json = Oj.load Post.find_json(post.id, include: :tags)
        expect(find_json).to eq(to_json)
      end

      it 'includes nested associations' do
        user = FactoryGirl.create :user
        post = FactoryGirl.create :post, author: user
        user.reload
        to_json = Oj.load user.to_json(include: {posts: {include: :forum}})
        find_json = Oj.load User.find_json(user.id, include: {posts: {include: :forum}})
        expect(find_json).to eq(to_json)
      end

      it 'includes nested associations with columns' do
        user = FactoryGirl.create :user
        post = FactoryGirl.create :post, author: user
        user.reload
        to_json = Oj.load user.to_json(include: {posts: {only: [:id], include: :forum}})
        find_json = Oj.load User.find_json(user.id, include: {posts: {columns: [:id], include: :forum}})
        expect(find_json).to eq(to_json)
      end
    end
  end

  describe 'all_json' do
    it 'is all rows as array' do
      users = FactoryGirl.create_list :user, 3
      to_json = Oj.load users.to_json
      all_json = Oj.load User.all_json
      expect(all_json).to eq(to_json)
    end
  end
end
