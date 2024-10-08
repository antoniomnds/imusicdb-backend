class CreateAlbumsAndGenres < ActiveRecord::Migration[7.2]
  def change
    create_table :albums_genres, id: false do |t|
      t.belongs_to :album, foreign_key: true, null: false
      t.belongs_to :genre, foreign_key: true, null: false
    end
  end
end
