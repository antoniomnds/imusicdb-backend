class CreateUsersAlbums < ActiveRecord::Migration[7.2]
  def change
    create_table :users_albums do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.belongs_to :album, null: false, foreign_key: true
      t.datetime :added_at

      t.timestamps
    end
  end
end
