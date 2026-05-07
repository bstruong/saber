module Api
  class InteractionsController < BaseController
    before_action :set_person
    before_action :set_interaction, only: [ :show, :void ]

    def index
      render json: @person.interactions.active
    end

    def show
      render json: @interaction
    end

    def create
      interaction = InteractionLogger.new(person: @person, attributes: interaction_params).call
      render json: interaction, status: :created
    rescue ActiveRecord::RecordInvalid => e
      render json: { errors: e.record.errors.full_messages }, status: :unprocessable_content
    end

    def void
      @interaction.update!(voided_at: Time.current)
      render json: @interaction
    end

    private

    def set_person
      @person = Person.active.find(params[:person_id])
    end

    def set_interaction
      @interaction = @person.interactions.find(params[:id])
    end

    def interaction_params
      params.require(:interaction).permit(:interaction_type, :occurred_at, :notes)
    end
  end
end
