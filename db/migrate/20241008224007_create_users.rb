class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      t.string :display_name
      t.string :email, index: { unique: true }, null: false
      t.string :spotify_id, null: false
      t.string :country

      t.timestamps
    end
  end
end
