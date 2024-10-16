# frozen_string_literal: true

class AlbumBlueprint < Blueprinter::Base
  identifier :id

  fields :name, :album_type, :total_tracks, :spotify_id, :release_date, :label,
         :popularity
  association :artists, blueprint: ArtistBlueprint
  association :genres, blueprint: GenreBlueprint
end
