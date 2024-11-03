module Api
  module V1
    class AlbumsController < Api::V1::RootController
      before_action :set_album, only: %i[show similar]

      def show
        render_json data: ::AlbumBlueprint.render(@album), status: :ok
      end

      def create
        album = AlbumsService.search_album(current_user, album_params)

        unless album
          return render_json errors: "Album couldn't be saved.", status: :bad_request
        end

        render_json data: ::AlbumBlueprint.render(album), status: :ok
      end

      def me
        albums = AlbumsService.saved_albums(current_user, params[:refresh] || false)

        render_json data: ::AlbumBlueprint.render(albums), status: :ok
      end

      def similar
        albums = AlbumsService.similar_albums(current_user, @album)

        render_json data: ::AlbumBlueprint.render(albums), status: :ok
      end


      private

      def set_album
        @album = Album.find(params[:id]) # exception is handled by the ApplicationController
      end

      def album_params
        params.require(:album).permit(:id, :album_type, :label, :name, :popularity, :spotify_id,
                               :total_tracks, :release_date, artists: %i[id name],
                               genres: %i[id name])
      end
    end
  end
end
