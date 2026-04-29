module Api
  class RemindersController < BaseController
    REMINDER_FIELDS = %i[id due_at reason snoozed_until dismissed_at].freeze

    before_action :set_reminder

    def dismiss
      @reminder.update!(dismissed_at: Time.current)
      render json: @reminder.as_json(only: REMINDER_FIELDS)
    end

    def snooze
      @reminder.update!(snoozed_until: params.require(:snoozed_until))
      render json: @reminder.as_json(only: REMINDER_FIELDS)
    end

    private

    def set_reminder
      @reminder = Reminder.find(params[:id])
    end
  end
end
