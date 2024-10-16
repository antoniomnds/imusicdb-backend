module Api
  module V1
    class AlbumsController < Api::V1::RootController
      def show
        album = Album.find(params[:id])

        render_json data: ::AlbumBlueprint.render(album), status: :ok
      end

      def me
        albums = AlbumsService.saved_albums(current_user, params[:refresh] || false)

        render_json data: ::AlbumBlueprint.render(albums), status: :ok
      end
    end
  end
end
