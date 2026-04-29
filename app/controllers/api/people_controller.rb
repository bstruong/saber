module Api
  class PeopleController < BaseController
    before_action :set_person, only: [ :show, :update, :destroy ]

    def index
      persons = Person.active
      persons = persons.where(ring: params[:ring]) if params[:ring].present?
      persons = persons.with_upcoming_events       if params[:upcoming_events] == "true"
      persons = persons.needs_reconnection         if params[:needs_reconnection] == "true"
      render json: persons
    end

    def show
      render json: @person
    end

    def create
      person = Person.new(person_params)
      if person.save
        render json: person, status: :created
      else
        render json: { errors: person.errors.full_messages }, status: :unprocessable_content
      end
    end

    def update
      if @person.update(person_params)
        render json: @person
      else
        render json: { errors: @person.errors.full_messages }, status: :unprocessable_content
      end
    end

    def destroy
      @person.soft_delete
      head :no_content
    end

    private

    def set_person
      @person = Person.active.find(params[:id])
    end

    def person_params
      params.require(:person).permit(
        :name,
        :ring,
        :notes,
        :needs,
        :connection_score,
        :score_source,
        :cadence_override_days,
        :last_connected_at,
        :importance_score,
        :reciprocity_score,
        :shared_values_score,
        relationship_tags: [],
        cultural_tags:     []
      )
    end
  end
end
