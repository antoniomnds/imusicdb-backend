require 'rails_helper'

RSpec.describe "Albums Request", type: :request do
  describe "Unauthorized access to albums" do
    it "denies access to albums#me" do
      get api_v1_albums_me_path

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "Authorized access to albums" do
    let(:albums) { create_list(:album, 5) }
    let(:user) { create(:user) }
    let(:oauth_access_token) { create(:oauth_access_token, user:) }

    it "returns saved albums" do
      allow(AlbumsService).to receive(:saved_albums).with(user, false).and_return(albums)

      get api_v1_albums_me_path, headers: { "HTTP_AUTHORIZATION": "Bearer #{ oauth_access_token.access_token }" }

      expect(response).to have_http_status(:ok)
      expect(AlbumsService).to have_received(:saved_albums).with(user, false)
    end
  end
end
