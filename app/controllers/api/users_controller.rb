module Api
  class UsersController < BaseController
    def me
      render json: { user: { id: current_user.id, email: current_user.email } }
    end
  end
end
