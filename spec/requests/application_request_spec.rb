require 'rails_helper'

RSpec.describe "Application Request", type: :request do
  describe "Authorized access to a resource" do
    context "with an expired access token" do
      let(:token) { create(:oauth_access_token, expires_at: DateTime.now - 30.minutes) }
      let(:renewed_token) { create(:oauth_access_token) }

      before do
        allow(::Api::SpotifyClient).to receive(:refresh_token).with(token).and_return(renewed_token)
      end

      it "returns the resource and the refreshed token" do
        get api_v1_albums_me_path, headers: { "HTTP_AUTHORIZATION": "Bearer #{ token.access_token }" }

        expect(response).to have_http_status(:ok)
        expect(response.headers["Authorization"]).not_to be_nil
      end
    end
  end
end
