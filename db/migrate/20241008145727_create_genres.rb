class CreateGenres < ActiveRecord::Migration[7.2]
  def change
    create_table :genres do |t|
      t.string :name, index: { unique: true }, null: false

      t.timestamps
    end
  end
end
