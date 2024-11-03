# frozen_string_literal: true

class AlbumsService
  class << self
    def saved_albums(user, refresh)
      new.saved_albums(user, refresh)
    end

    def similar_albums(user, album)
      new.similar_albums(user, album)
    end

    def search_album(user, album_data)
      new.search_album(user, album_data)
    end
  end

  def saved_albums(user, refresh)
    if refresh
      results = ::Api::SpotifyClient.fetch_saved_albums(user)
      albums = process_saved_albums(results, user)
      return albums
    end
    Album.with_artists.with_genres.for_user(user)
  end

  def similar_albums(user, album)
    except_albums = user.albums.with_artists.map do |al|
      "#{ al.name } from #{ al.artists.map(&:name).join(", ") } released in #{ al.release_date }"
    end.join(", ")

    message = <<~HEREDOC.squish
      Please tell me five similar albums to the album named #{ album.name }
      of artists #{ album.artists.map(&:name).join(", ") } released in
      #{ album.release_date }.
    HEREDOC
    message << " Please do not include in the results the following albums: #{except_albums}" unless except_albums.empty?

    result = Api::OpenaiClient.send_prompt(message)
    process_similar_albums(result)
  end

  def search_album(user, album_data)
    spotify_id = ::Api::SpotifyClient.search_album(user, album_data)
    return unless spotify_id

    result = ::Api::SpotifyClient.fetch_album(user, spotify_id)
    process_album(result, user)
  end

  private

  def process_saved_albums(results, user)
    albums = []
    ActiveRecord::Base.transaction do
      results.each do |result|
        result["items"].each do |item|
          album = process_album(item["album"], user, item["added_at"])
          albums << album
        end
      end
    end
    albums
  end

  def process_album(album_data, user, added_at = nil)
    ActiveRecord::Base.transaction do
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
        %i[name album_type total_tracks release_date label popularity].each do |attr|
          al.send("#{attr}=", album_data["#{attr}"])
        end
        al.artists << artists
        al.genres << genres
      end
      album.users_albums.find_or_create_by!(user:, album:) do |ua|
        ua.added_at = added_at
      end
      album
    end
  end

  def process_similar_albums(result)
    albums = []
    result["albums"].each do |album_data|
      album = Album.build.tap do |album|
        %i[name release_date label total_tracks].each do |attr|
          album.send("#{attr}=", album_data["#{attr}"])
        end
      end
      album_data["artists"].each do |artist_data|
        album.artists << Artist.build({name: artist_data["name"]})
      end
      album_data["genres"].each do |genre_data|
        album.genres << Genre.build({name: genre_data["name"]})
      end
      albums << album
    end
    albums
  end
end
