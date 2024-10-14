FactoryBot.define do
  factory :oauth_access_token do
    app { Faker::App.name }
    access_token { Faker::Internet.device_token }
    refresh_token { Faker::Internet.device_token }
    expires_at { Faker::Time.between(from: DateTime.now, to: DateTime.now + 1.hour) }
  end
end
