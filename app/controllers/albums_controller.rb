class AlbumsController < ApplicationController
  def me
    albums = AlbumsService.saved_albums(params[:refresh] || false)

    render json: albums.to_json(except: %i[id created_at updated_at]), status: :ok
  end
end
