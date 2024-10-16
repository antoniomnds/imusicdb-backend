require 'rails_helper'

RSpec.describe "Users Request", type: :request do
  describe "Unauthorized access to the user" do
    it "denies access to users#me" do
      get api_v1_users_me_path

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "Authorized access to the user" do
    let(:user) { create(:user) }
    let(:token) { create(:oauth_access_token, user:) }

    before do
      allow(JwtService).to receive(:decode).and_return(token.access_token)
    end

    it "returns the user" do
      get api_v1_users_me_path, headers: { "HTTP_AUTHORIZATION": "Bearer #{ token.access_token }" }

      expect(response).to have_http_status(:ok)
    end
  end
end
