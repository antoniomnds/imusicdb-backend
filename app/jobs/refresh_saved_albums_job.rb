class RefreshSavedAlbumsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    User.all.each do |user|
      AlbumsService.saved_albums(user, true)
    end
  end
end
