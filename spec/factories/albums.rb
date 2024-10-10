FactoryBot.define do
  factory :album do
    name { Faker::Music.album }
    total_tracks { Faker::Number.between(from: 0, to: 15) }
    spotify_id { Faker::Internet.base64(length: 62) }
    release_date { Faker::Date.between(from: 30.years.ago, to: Date.today) }
    label { Faker::Name.middle_name }
    user
  end
end
