module Api
  class ContactsController < BaseController
    before_action :set_person, only: [ :show, :update, :destroy ]

    def index
      persons = Person.active
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
        render json: { errors: person.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def update
      if @person.update(person_params)
        render json: @person
      else
        render json: { errors: @person.errors.full_messages }, status: :unprocessable_entity
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
        :soi_score,
        :score_source,
        :cadence_override_days,
        :last_contacted_at,
        :importance_score,
        :value_exchange_score,
        :objective_alignment_score,
        relationship_tags: [],
        cultural_tags:     []
      )
    end
  end
end
