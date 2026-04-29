# Single Responsibility - only creates reminders for drifted people
class DriftDetector
  def self.call(...)
    new(...).call
  end

  # Strategy as callable - generator injected for specs
  def initialize(generator: PromptGenerator)
    @generator = generator
  end

  def call
    drifted_people.each { |person| remind(person) }
  end


  private

  attr_reader :generator

  def drifted_people
    Person.active.needs_reconnection
  end

  def remind(person)
    return if person.reminders.active.exists?

    person.reminders.create!(
      reason: generator.new(person).generate,
      due_at: Date.today
    )
  end
end
