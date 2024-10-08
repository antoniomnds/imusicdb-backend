# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2024_10_08_150700) do
  create_table "albums", force: :cascade do |t|
    t.string "name", null: false
    t.string "album_type"
    t.integer "total_tracks", null: false
    t.datetime "added_at"
    t.string "spotify_id"
    t.string "release_date", null: false
    t.string "label", null: false
    t.integer "popularity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["spotify_id"], name: "index_albums_on_spotify_id", unique: true
  end

  create_table "albums_artists", id: false, force: :cascade do |t|
    t.integer "album_id", null: false
    t.integer "artist_id", null: false
    t.index ["album_id"], name: "index_albums_artists_on_album_id"
    t.index ["artist_id"], name: "index_albums_artists_on_artist_id"
  end

  create_table "albums_genres", id: false, force: :cascade do |t|
    t.integer "album_id", null: false
    t.integer "genre_id", null: false
    t.index ["album_id"], name: "index_albums_genres_on_album_id"
    t.index ["genre_id"], name: "index_albums_genres_on_genre_id"
  end

  create_table "artists", force: :cascade do |t|
    t.string "name", null: false
    t.string "spotify_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["spotify_id"], name: "index_artists_on_spotify_id", unique: true
  end

  create_table "genres", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_genres_on_name", unique: true
  end

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.string "app", null: false
    t.string "access_token", null: false
    t.string "refresh_token", null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["access_token"], name: "index_oauth_access_tokens_on_access_token", unique: true
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
  end

  add_foreign_key "albums_artists", "albums"
  add_foreign_key "albums_artists", "artists"
  add_foreign_key "albums_genres", "albums"
  add_foreign_key "albums_genres", "genres"
end
