module Api
  module V1
    class AlbumsController < Api::V1::RootController
      before_action :set_album, only: %i[show similar]

      def show
        render_json data: ::AlbumBlueprint.render(@album), status: :ok
      end

      def me
        albums = AlbumsService.saved_albums(current_user, params[:refresh] || false)

        render_json data: ::AlbumBlueprint.render(albums), status: :ok
      end

      def similar
        albums = AlbumsService.similar_albums(@album)

        render_json data: ::AlbumBlueprint.render(albums), status: :ok
      end


      private

      def set_album
        @album = Album.find(params[:id]) # exception is handled by the ApplicationController
      end
    end
  end
end
