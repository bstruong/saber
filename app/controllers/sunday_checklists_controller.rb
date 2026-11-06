class SundayChecklistsController < ApplicationController
  def update
    @sunday_checklist = SundayChecklist.for_current_week
    if @sunday_checklist.update(checklist_params)
      redirect_back fallback_location: root_path, notice: "Checklist updated."
    else
      redirect_back fallback_location: root_path, alert: @sunday_checklist.errors.full_messages.to_sentence
    end
  end

  private

  def checklist_params
    params.require(:sunday_checklist).permit(*SundayChecklist::CHECK_ATTRIBUTES)
  end
end
