class OauthAccessToken < ApplicationRecord
  belongs_to :user, optional: true # access token is created before its user

  def expired?
    DateTime.now > expires_at
  end
end
