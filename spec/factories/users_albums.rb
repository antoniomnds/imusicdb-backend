FactoryBot.define do
  factory :users_album do
    user
    album
    added_at { Faker::Date.between(from: 10.year.ago, to: Date.today) }
  end
end
