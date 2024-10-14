class Album < ApplicationRecord
  has_and_belongs_to_many :artists
  has_and_belongs_to_many :genres
  has_many :users_albums
  has_many :users, through: :users_albums

  scope :for_user, ->(user) { joins(:users).where(users: user) }
end
