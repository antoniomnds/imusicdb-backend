class ApplicationController < ActionController::API
  before_action :authorize

  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  def authorize
    return if ::Api::SpotifyClient.get_access_token

    redirect_to spotify_oauth_request_authorization_url, status: :see_other
  end

  private

  def not_found
    render json: "The resource you're looking for was not found.", status: 404
  end
end
