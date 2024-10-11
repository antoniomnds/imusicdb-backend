class ApplicationController < ActionController::API
  before_action :authorize

  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  def authorize
    auth_header = request.headers["HTTP_AUTHORIZATION"]
    access_token = auth_header&.match?(/Bearer \w+/) && auth_header.gsub(/Bearer /, "")
    token = access_token && OauthAccessToken.find_by(access_token: access_token)

    unless token
      return render json: { error: "You have to authenticate." }, status: :unauthorized
    end

    if token.expired?
      new_token = ::Api::SpotifyClient.refresh_token(token)
      unless new_token
        return render json: { error: "Failed to refresh the token." }, status: :bad_request
      end
      response.set_header("Authorization", "Bearer #{ new_token.access_token }")
    end

    self.current_user = token.user
  end

  def current_user
    @current_user
  end

  def current_user=(user)
    @current_user = user
  end


  private

  def not_found
    render json: "The resource you're looking for was not found.", status: 404
  end
end
