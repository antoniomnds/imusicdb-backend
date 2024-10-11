module Api
  module V1
    class SpotifyOauthController < RootController
      skip_before_action :authorize, only: %i[request_authorization callback]

      def request_authorization
        base_url = URI("https://accounts.spotify.com/authorize")
        state = SecureRandom.hex(24) # to protect against CSRF
        Rails.cache.write(state, true, expires_in: 10.minutes)
        query_params = {
          client_id: ENV["SPOTIFY_CLIENT_ID"],
          response_type: "code",
          redirect_uri: api_v1_spotify_oauth_callback_url,
          scope: "user-library-read user-read-email"
        }
        query = URI.encode_www_form(query_params)
        url = "#{ base_url }?#{ query }"

        redirect_to url, allow_other_host: true, status: :see_other
      end

      def callback
        if params[:error]
          return render_json errors: "Authorization not granted: #{ params[:error] }.", status: :unauthorized
        end

        authorization_code = params[:code]
        unless authorization_code
          return render_json errors: "Did not receive the authorization code. Return and try again.", status: :unauthorized
        end

        token = ::Api::SpotifyClient.fetch_access_token(authorization_code, api_v1_spotify_oauth_callback_url)
        unless token
          return render_json errors: "Failed to get the access token", status: :bad_request
        end

        ::Api::SpotifyClient.fetch_user_info(token)

        render_json data: token.access_token, status: :ok
      end
    end
  end
end
