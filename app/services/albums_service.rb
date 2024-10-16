# frozen_string_literal: true

class AlbumsService
  class << self
    def saved_albums(user, refresh)
      new(user).saved_albums(refresh)
    end
  end

  attr_reader :user

  def initialize(user)
    @user = user
  end

  def saved_albums(refresh)
    if refresh
      results = ::Api::SpotifyClient.fetch_saved_albums(user)
      albums = process_saved_albums(results)
      return albums
    end
    Album.with_artists.with_genres.for_user(user)
  end


  private

  def process_saved_albums(results)
    albums = []
    ActiveRecord::Base.transaction do
      results.each do |result|
        result["items"].each do |item|
          album_data = item["album"]
          artists = []
          album_data["artists"].each do |artist_data|
            artists << Artist.find_or_create_by!(spotify_id: artist_data["id"]) do |a|
              a.name = artist_data["name"]
            end
          end
          genres = []
          album_data["genres"].each do |genre_data|
            genres << Genre.find_or_create_by!(name: genre_data)
          end
          album = Album.find_or_create_by!(spotify_id: album_data["id"]) do |al|
            al.name = album_data["name"]
            al.album_type = album_data["type"]
            al.total_tracks = album_data["total_tracks"]
            al.release_date = album_data["release_date"]
            al.label = album_data["label"]
            al.popularity = album_data["popularity"]
            al.artists << artists
            al.genres << genres
          end
          album.users_albums.find_or_create_by!(user:, album:) do |ua|
            ua.added_at = item["added_at"]
          end
          albums << album
        end
      end
    end
    albums
  end
end
