class ApplicationController < ActionController::API
  before_action :authorize

  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  def authorize
    return if current_user && ::Api::SpotifyClient.get_access_token(current_user)

    redirect_to spotify_oauth_request_authorization_url, status: :see_other
  end

  def current_user
    @current_user ||= Rails.cache.read("current_user") &&
      User.find_by(id: Rails.cache.read("current_user"))
  end

  def current_user=(user)
    Rails.cache.write("current_user", user.id)
  end

  private

  def not_found
    render json: "The resource you're looking for was not found.", status: 404
  end
end
