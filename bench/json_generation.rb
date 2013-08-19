require 'benchmark_helper'
require 'faker'
require 'factory_girl'
FactoryGirl.find_definitions

print "Generating test data... "

clean_database

Forum.transaction do
  forums = FactoryGirl.create_list :forum, 4
  users = FactoryGirl.create_list :user, 20
  tags = FactoryGirl.create_list :tag, 30
  50.times do
    FactoryGirl.create :post, forum: forums.sample, author: users.sample, tags: tags.sample(rand(0..5))
  end
end

puts "Done."

num_short_iterations = 500
num_long_iterations = 20

Benchmark.bm(55) do |x|
  first_post = Post.first
  x.report("find_json: 1 record #{num_short_iterations} times") do
    num_short_iterations.times do
      Post.find_json first_post.id
    end
  end

  x.report("to_json:   1 record #{num_short_iterations} times") do
    num_short_iterations.times do
      Post.find(first_post.id).to_json
    end
  end

  x.report("find_json: 1 record with 3 associations #{num_short_iterations} times") do
    num_short_iterations.times do
      Post.find_json first_post.id, include: [:author, :forum, :tags]
    end
  end

  x.report("to_json:   1 record with 3 associations #{num_short_iterations} times") do
    num_short_iterations.times do
      Post.includes(:author, :forum).find(first_post.id).to_json include: [:author, :forum, :tags]
    end
  end

  x.report("all_json:  50 records with 3 associations #{num_long_iterations} times") do
    num_long_iterations.times do
      Post.all_json include: [:author, :forum, :tags]
    end
  end

  x.report("to_json:   50 records with 3 associations #{num_long_iterations} times") do
    num_long_iterations.times do
      Post.includes(:author, :forum).to_a.to_json include: [:author, :forum, :tags]
    end
  end
end
