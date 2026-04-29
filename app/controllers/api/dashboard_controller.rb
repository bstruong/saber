module Api
  class DashboardController < BaseController
    PERSON_FIELDS = %i[id name ring last_contacted_at].freeze

    def reconnect
      reminders = Reminder.active.not_snoozed.order(:due_at).includes(:person)
      render json: reminders.as_json(
        only:    %i[id due_at reason snoozed_until],
        include: { person: { only: PERSON_FIELDS } }
      )
    end

    def upcoming
      groups = UpcomingView.call.map do |group|
        { person:         group[:person].as_json(only: PERSON_FIELDS),
          upcoming_dates: group[:upcoming_dates] }
      end
      render json: groups
    end
  end
end
