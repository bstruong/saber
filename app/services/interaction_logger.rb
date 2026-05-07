# Single Responsibility - coordinates interaction-create side effects
class InteractionLogger
  def initialize(person:, attributes:)
    @person     = person
    @attributes = attributes
  end

  def call
    Interaction.transaction do
      interaction = @person.interactions.create!(@attributes)
      advance_last_connected_at(interaction.occurred_at)
      dismiss_active_reminder
      interaction
    end
  end

  private

  # MAX semantics - backdated occurred_at never moves last_connected_at backward
  def advance_last_connected_at(occurred_at)
    candidate = occurred_at.in_time_zone.beginning_of_day
    return if @person.last_connected_at && @person.last_connected_at >= candidate
    @person.update!(last_connected_at: candidate)
  end

  # Tell, don't ask
  def dismiss_active_reminder
    @person.reminders.where(dismissed_at: nil).update_all(dismissed_at: Time.current)
  end
end
