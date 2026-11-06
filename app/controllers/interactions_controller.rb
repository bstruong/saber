class InteractionsController < ApplicationController
  def create
    contact = Contact.find(params[:contact_id])
    InteractionLogger.call(contact:, attrs: interaction_params)
    redirect_to contact_path(contact), notice: "Interaction saved."
  rescue ActiveRecord::RecordInvalid => e
    redirect_to contact_path(contact), alert: e.record.errors.full_messages.to_sentence
  end

  private

  def interaction_params
    params.require(:interaction).permit(
      :interaction_type, :hook_em_notes, :help_em_notes, :ask_em_notes
    )
  end
end
