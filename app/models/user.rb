class User < ApplicationRecord
  has_one :oauth_access_token
  has_many :users_albums
  has_many :albums, through: :users_albums
end
