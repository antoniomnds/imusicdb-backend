module Api
  module V1
    class AlbumsController < Api::V1::RootController
      def me
        albums = AlbumsService.saved_albums(current_user, params[:refresh] || false)

        render_json data: albums.to_json(except: %i[id created_at updated_at]), status: :ok
      end
    end
  end
end
