# frozen_string_literal: true

module Api
  class SpotifyClient < Client
    if Rails.env.local?
      REDIRECT_URI = "http://localhost:3000/spotify_oauth/callback".freeze
    else
      raise NotImplementedError("Oauth redirect URI not defined.")
    end

    class << self
      def fetch_access_token(code)
        new.send(:fetch_access_token, code)
      end

      def get_access_token
        new.send(:get_access_token)
      end

      def fetch_saved_albums
        new.send(:fetch_saved_albums)
      end
    end

    attr_reader :client_id, :client_secret

    def initialize
      @client_id = ENV["SPOTIFY_CLIENT_ID"]
      @client_secret = ENV["SPOTIFY_CLIENT_SECRET"]
    end


    protected

    # Returns a valid (not expired) access token object,
    # or nil if token refresh didn't succeed.
    def get_access_token
      access_token = OauthAccessToken.last
      if access_token&.expired?
        access_token = refresh_token(access_token)
      end
      access_token
    end

    def fetch_access_token(code)
      data = URI.encode_www_form({
                                   grant_type: "authorization_code",
                                   code: code,
                                   redirect_uri: REDIRECT_URI
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
        rescue ActiveRecord::RecordInvalid
          Rails.logger.error("Failed to save the access token")
        end
      else
        log_response("Failed to authenticate", response, :error)
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
        rescue ActiveRecord::RecordInvalid
          Rails.logger.error("Failed to update the access token")
        end
      else
        log_response("Failed to revalidate the access token", response, :error)
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
