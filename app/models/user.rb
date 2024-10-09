class User < ApplicationRecord
  has_one :oauth_access_token
  has_many :albums
end
