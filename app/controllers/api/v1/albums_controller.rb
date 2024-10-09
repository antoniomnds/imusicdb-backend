class Api::V1::AlbumsController < ApplicationController
  def me
    albums = AlbumsService.saved_albums(current_user, params[:refresh] || false)

    render json: albums.to_json(except: %i[id created_at updated_at]), status: :ok
  end
end
