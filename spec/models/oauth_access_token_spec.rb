require 'rails_helper'

RSpec.describe OauthAccessToken, type: :model do
  subject(:token) { create(:oauth_access_token) }

  describe "#is_expired?" do
    context "with expire date in the past" do
      it "should return true" do
        token.expires_at = DateTime.now - 30.minutes
        expect(token.expired?).to be(true)
      end
    end

    context "with expire date in the future" do
      it "should return false" do
        token.expires_at = DateTime.now + 30.minutes
        expect(token.expired?).to be(false)
      end
    end
  end
end
