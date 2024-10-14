class Album < ApplicationRecord
  has_and_belongs_to_many :artists
  has_and_belongs_to_many :genres
  has_many :users_albums
  has_many :users, through: :users_albums

  validates :name,
            presence: true

  validates :total_tracks,
            presence: true,
            numericality: {
              only_integer: true,
              greater_than: 0
            }

  validates :release_date,
            presence: true

  validates :label,
            presence: true

  scope :for_user, ->(user) { joins(:users).where(users: user) }
end
