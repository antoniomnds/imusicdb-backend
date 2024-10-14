FactoryBot.define do
  factory :genre do
    name { Faker::Music.genre }
  end
end
