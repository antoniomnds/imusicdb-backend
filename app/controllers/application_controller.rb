class ApplicationController < ActionController::API
  before_action :authorize

  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  def authorize
    unless current_user
      render json: { error: "You have to authenticate." }, status: :unauthorized
    end
  end

  def current_user
    access_token = request.headers["HTTP_AUTHORIZATION"]&.match?(/Bearer \w+/) &&
      request.headers["HTTP_AUTHORIZATION"].gsub(/Bearer /, "")

    @current_user ||= access_token && OauthAccessToken.find_by(access_token: access_token)&.user
  end


  private

  def not_found
    render json: "The resource you're looking for was not found.", status: 404
  end
end
