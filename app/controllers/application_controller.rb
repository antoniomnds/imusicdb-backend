class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  def current_user
    @current_user
  end

  def current_user=(user)
    @current_user = user
  end


  private

  def not_found
    render json: { errors: "The resource you're looking for was not found." }, status: 404
  end
end
