# frozen_string_literal: true

module Api
  module V1
    class RootController < ApplicationController
      def render_json(data: {}, message: nil, errors: nil, status: :ok)
        render json: { data:, message:, errors: }, status:
      end
    end
  end
end
