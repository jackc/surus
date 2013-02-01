FactoryGirl.define do
  factory :post do
    author
    subject { Faker::Lorem.sentence  }
    body { Faker::Lorem.paragraph }
  end

  factory :user, aliases: [:author] do
    name { Faker::Internet.user_name }
    email { Faker::Internet.email }
  end
end
