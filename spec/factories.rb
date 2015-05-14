FactoryGirl.define do
  factory :forum do
    name { Faker::Lorem.sentence }
  end

  factory :post do
    forum
    author
    subject { Faker::Lorem.sentence  }
    body { Faker::Lorem.paragraph }
  end

  factory :tag do
    sequence(:name) { |n| "#{Faker::Lorem.word} - #{n}" }
  end

  factory :user, aliases: [:author] do
    name { Faker::Internet.user_name }
    email { Faker::Internet.email }
    after(:build) do |user|
      user.bio ||= FactoryGirl.build(:bio, author: user)
      user.avatar ||= FactoryGirl.build(:avatar, author: user)
    end
  end

  factory :bio do
    author
    body { Faker::Lorem.paragraph }
    website_url { Faker::Internet.url }
  end

  factory :avatar do
    author
    url { Faker::Avatar.image }
  end
end
