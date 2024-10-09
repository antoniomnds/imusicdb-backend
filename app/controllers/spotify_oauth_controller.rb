class SpotifyOauthController < ApplicationController
  skip_before_action :authorize, only: %i[request_authorization callback]

  def request_authorization
    base_url = URI("https://accounts.spotify.com/authorize")
    state = SecureRandom.hex(24) # to protect against CSRF
    Rails.cache.write(state, true, expires_in: 10.minutes)
    query_params = {
      client_id: ENV["SPOTIFY_CLIENT_ID"],
      response_type: "code",
      redirect_uri: ::Api::SpotifyClient::REDIRECT_URI,
      state: state,
      scope: "user-library-read user-read-email"
    }
    query = URI.encode_www_form(query_params)
    url = "#{ base_url }?#{ query }"

    redirect_to url, allow_other_host: true, status: :see_other
  end

  def callback
    if params[:error]
      return render json: { error: "Authorization not granted: #{ params[:error] }." }, status: :unauthorized
    end

    authorization_code = params[:code]
    received_state = params[:state]
    cached_state = Rails.cache.read(received_state)

    unless cached_state
      return render json: { error: "State mismatch. Possible CSRF. Return and try again." }, status: :unauthorized
    end

    unless authorization_code
      return render json: { error: "Did not receive the authorization code. Return and try again." }, status: :unauthorized
    end

    access_token = ::Api::SpotifyClient.fetch_access_token(authorization_code)
    self.current_user = ::Api::SpotifyClient.fetch_user_info(access_token)

    render json: "Authorization granted successfully.", status: :ok
  end
end
