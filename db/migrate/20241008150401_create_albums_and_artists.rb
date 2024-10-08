class CreateAlbumsAndArtists < ActiveRecord::Migration[7.2]
  def change
    create_table :albums_artists, id: false do |t|
      t.belongs_to :album, foreign_key: true, null: false
      t.belongs_to :artist, foreign_key: true, null: false
    end
  end
end
