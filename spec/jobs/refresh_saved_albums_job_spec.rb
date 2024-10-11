require 'rails_helper'

RSpec.describe RefreshSavedAlbumsJob, type: :job do
  include ActiveJob::TestHelper

  before do
    ActiveJob::Base.queue_adapter = :test
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end

  describe "#perform_later" do
    it "enqueues the job" do
      expect { RefreshSavedAlbumsJob.perform_later }.to have_enqueued_job.on_queue("default")
    end
  end

  describe "#perform_now" do
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }
    let(:albums) { create_list(:album, 2) }
    let(:album_data) { %w[album_1_data album_2_data] }

    before do
      allow(User).to receive(:all).and_return([ user1, user2 ])
      allow(AlbumsService).to receive(:saved_albums).with(user1, true).and_return(albums)
      allow(AlbumsService).to receive(:saved_albums).with(user2, true).and_return(albums)
    end

    it "performs the job" do
      expect(AlbumsService).to receive(:saved_albums).with(user1, true).once
      expect(AlbumsService).to receive(:saved_albums).with(user2, true).once
      expect { RefreshSavedAlbumsJob.perform_now }.not_to raise_error
    end
  end

end
