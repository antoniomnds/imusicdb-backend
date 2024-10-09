class AddUserToAlbum < ActiveRecord::Migration[7.2]
  def change
    add_belongs_to :albums, :user, null: false, foreign_key: true
  end
end
