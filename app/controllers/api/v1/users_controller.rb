module Api
  module V1
    class UsersController < RootController
      before_action :set_user, only: %i[ me ]

      def me
        render_json data: @user.to_json(except: %i[id created_at updated_at]), status: :ok
      end


      private

      def set_user
        unless current_user
          raise ActiveRecord::RecordNotFound
        end
        @user = current_user
      end
    end
  end
end
