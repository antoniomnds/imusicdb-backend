# frozen_string_literal: true

module Api
  class SpotifyClient < Client
    class << self
      def fetch_access_token(code, redirect_url)
        new.fetch_access_token(code, redirect_url)
      end

      def refresh_token(token)
        new.refresh_token(token)
      end

      def fetch_saved_albums(user)
        new(user).fetch_saved_albums
      end

      def fetch_user_info(access_token)
        new.fetch_user_info(access_token)
      end

      def search_album(user, album_data)
        new(user).search_album(album_data)
      end

      def fetch_album(user, spotify_id)
        new(user).fetch_album(spotify_id)
      end
    end

    attr_reader :client_id, :client_secret, :user

    def initialize(user = nil)
      @client_id = ENV["SPOTIFY_CLIENT_ID"]
      @client_secret = ENV["SPOTIFY_CLIENT_SECRET"]
      @user = user
    end


    def get_access_token
      user&.oauth_access_token
    end

    def fetch_access_token(code, redirect_url)
      data = URI.encode_www_form({
                                   grant_type: "authorization_code",
                                   code: code,
                                   redirect_uri: redirect_url
                                 })
      response = request_token(data)
      if response.is_a?(Net::HTTPSuccess)
        data = JSON.parse(response.body)
        begin
          OauthAccessToken.create!(
            app: "spotify",
            access_token: data["access_token"],
            refresh_token: data["refresh_token"],
            expires_at: DateTime.now + data["expires_in"].seconds
          )
        rescue ActiveRecord::RecordInvalid => e
          Rails.logger.error { "Failed to save the access token: #{ e.message }" }
          nil
        end
      else
        log_response("Failed to authenticate", response, :error)
        nil
      end
    end

    def refresh_token(token)
      data = URI.encode_www_form({
                                   grant_type: "refresh_token",
                                   refresh_token: token.refresh_token
                                 })
      response = request_token(data)
      if response.is_a?(Net::HTTPSuccess)
        data = JSON.parse(response.body)
        begin
          token.update!(
            access_token: data["access_token"],
            refresh_token: data["refresh_token"] || token.refresh_token,
            expires_at: DateTime.now + data["expires_in"].seconds
          )
          token
        rescue ActiveRecord::RecordInvalid => e
          Rails.logger.error { "Failed to update the access token: #{ e.message }" }
          nil
        end
      else
        log_response("Failed to revalidate the access token", response, :error)
        nil
      end
    end

    def fetch_saved_albums
      base_url = URI("https://api.spotify.com/v1/me/albums")
      headers = {
        "Authorization": "Bearer #{ get_access_token.access_token }"
      }
      query_params = URI.encode_www_form({
                                           limit: 5
                                         })
      uri = URI("#{ base_url }?#{ query_params }")
      results = []

      loop do
        response = Net::HTTP.get_response(uri, headers)
        if response.is_a? Net::HTTPSuccess
          data = JSON.parse(response.body)
          results << data
          next_url = data["next"]
          uri = URI(next_url) if next_url
          break unless next_url and uri
        else
          log_response("Failed to get saved albums", response, :error)
          break
        end
      end
      results
    end

    def fetch_user_info(token)
      uri = URI("https://api.spotify.com/v1/me")
      headers = {
        "Authorization": "Bearer #{ token.access_token }"
      }
      response = Net::HTTP.get_response(uri, headers)
      if response.is_a? Net::HTTPSuccess
        data = JSON.parse(response.body)
        user = nil
        ActiveRecord::Base.transaction do
          user = User.find_or_create_by!(email: data["email"]) do |u|
            u.display_name = data["display_name"]
            u.spotify_id = data["id"]
            u.country = data["country"]
          end
          token.update(user: user)
        end
        user
      else
        log_response("Failed to get user information", response, :error)
      end
    end

    def search_album(album_data)
      base_url = URI("https://api.spotify.com/v1/search")
      headers = { "Authorization": "Bearer #{ get_access_token.access_token }" }

      artists_data = album_data["artists"].map { |artist_data| artist_data["name"] }.join(", ")
      year_data = Date.parse(album_data["release_date"]).year
      filters = "artist:#{artists_data} album:#{album_data["name"]} year:#{year_data}"
      query_params = URI.encode_www_form({ q: filters, type: "album", limit: 1 })

      uri = URI("#{ base_url }?#{ query_params }")
      response = Net::HTTP.get_response(uri, headers)
      debugger
      if response.is_a? Net::HTTPSuccess
        data = JSON.parse(response.body)
        data.dig("albums", "items", 0, "id") # returns the spotify_id of the first album
      else
        log_response("Failed to get album", response, :error)
      end
    end

    def fetch_album(spotify_id)
      uri = URI("https://api.spotify.com/v1/albums/#{spotify_id}")
      headers = {
        "Authorization": "Bearer #{ get_access_token.access_token }"
      }
      response = Net::HTTP.get_response(uri, headers)
      if response.is_a? Net::HTTPSuccess
        JSON.parse(response.body)
      else
        log_response("Failed to get album", response, :error)
      end
    end

    private

    def request_token(data)
      uri = URI("https://accounts.spotify.com/api/token")

      req = Net::HTTP::Post.new(uri)
      req.basic_auth(client_id, client_secret)
      req.content_type = "application/x-www-form-urlencoded"
      req.body = data
      Net::HTTP.start(uri.hostname, use_ssl: true) do |http|
        http.request(req)
      end
    end
  end
end
