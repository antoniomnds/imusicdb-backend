class CreateAlbums < ActiveRecord::Migration[7.2]
  def change
    create_table :albums do |t|
      t.string :name, null: false
      t.string :album_type
      t.integer :total_tracks, null: false
      t.string :spotify_id, index: { unique: true }
      t.string :release_date, null: false
      t.string :label, null: false
      t.integer :popularity

      t.timestamps
    end
  end
end
