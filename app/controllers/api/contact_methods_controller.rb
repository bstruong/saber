module Api
  class ContactMethodsController < BaseController
    before_action :set_person

    def create
      method = @person.contact_methods.new(contact_method_params)
      if method.save
        render json: method, status: :created
      else
        render json: { errors: method.errors.full_messages }, status: :unprocessable_content
      end
    end

    def destroy
      method = @person.contact_methods.find(params[:id])
      method.destroy
      head :no_content
    end

    private

    def set_person
      @person = Person.active.find(params[:contact_id])
    end

    def contact_method_params
      params.require(:contact_method).permit(:method_type, :value)
    end
  end
end
