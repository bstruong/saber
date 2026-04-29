module Api
  class ImportantDatesController < BaseController
    before_action :set_person

    def create
      date = @person.important_dates.new(important_dates_params)
      if date.save
        render json: date, status: :created
      else
        render json: { errors: date.errors.full_messages }, status: :unprocessable_content
      end
    end

    def destroy
      date = @person.important_dates.find(params[:id])
      date.destroy
      head :no_content
    end

    private

    def set_person
      @person = Person.active.find(params[:person_id])
    end

    def important_dates_params
      params.require(:important_date).permit(:name, :month, :day)
    end
  end
end
