module Api
  # Single Responsibility - JSON wrapper around Devise sessions
  class SessionsController < Devise::SessionsController
    respond_to :json

    private

    def respond_with(resource, _opts = {})
      render json: serialize(resource), status: :ok
    end

    def respond_to_on_destroy(non_navigational_status: :no_content)
      head non_navigational_status
    end

    def serialize(user)
      { user: { id: user.id, email: user.email } }
    end
  end
end
