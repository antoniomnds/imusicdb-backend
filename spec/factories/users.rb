FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    spotify_id { Faker::Internet.base64(length: 62) }
  end
end
