# frozen_string_literal: true

class AlbumsService
  class << self
    def saved_albums(refresh)
      new.send(:saved_albums, refresh)
    end
  end


  protected

  def saved_albums(refresh)
    if refresh
      results = ::Api::SpotifyClient.fetch_saved_albums
      results.each do |result|
        process_saved_album(result)
      end
    end
    Album.all # TODO restrict by user
  end


  private

  def process_saved_album(result)
    ActiveRecord::Base.transaction do
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
        Album.find_or_create_by!(spotify_id: album_data["id"]) do |al|
          al.name = album_data["name"]
          al.added_at = item["added_at"]
          al.album_type = album_data["type"]
          al.total_tracks = album_data["total_tracks"]
          al.release_date = album_data["release_date"]
          al.label = album_data["label"]
          al.popularity = album_data["popularity"]
          al.artists << artists
          al.genres << genres
        end
      end
    end
  end
end
