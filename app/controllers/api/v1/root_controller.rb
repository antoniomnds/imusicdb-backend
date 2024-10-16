# frozen_string_literal: true

module Api
  module V1
    class RootController < ApplicationController
      before_action :authorize

      def authorize
        auth_header = request.headers["HTTP_AUTHORIZATION"]
        access_token = auth_header&.match?(/Bearer \w+/) && auth_header.gsub(/Bearer /, "")

        begin
          decoded_token = JwtService.decode(access_token)
        rescue JWT::DecodeError
          return render_json errors: "Invalid token.", status: :unauthorized
        end

        token = decoded_token && OauthAccessToken.find_by(access_token: decoded_token)
        unless token
          return render_json errors: "You have to authenticate.", status: :unauthorized
        end

        if token.expired?
          new_token = ::Api::SpotifyClient.refresh_token(token)
          unless new_token
            return render_json errors: "Failed to refresh the token.", status: :bad_request
          end
          encoded_access_token = JwtService.encode(new_token.access_token)
          response.set_header("Authorization", "Bearer #{ encoded_access_token }")
          token = new_token
        end

        self.current_user = token.user
      end

      def render_json(data: {}, message: nil, errors: nil, status: :ok)
        render json: { data:, message:, errors: }, status:
      end
    end
  end
end
