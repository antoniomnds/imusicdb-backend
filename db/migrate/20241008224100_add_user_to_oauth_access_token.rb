class AddUserToOauthAccessToken < ActiveRecord::Migration[7.2]
  def change
    add_belongs_to :oauth_access_tokens, :user, foreign_key: true
  end
end
