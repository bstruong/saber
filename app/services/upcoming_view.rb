# Single Responsibility - only shapes upcoming events for the dashboard
class UpcomingView
  WINDOW = Person::UPCOMING_DAYS_WINDOW

  def self.call(...)
    new(...).call
  end

  def initialize(today: Date.today, window: WINDOW)
    @today  = today
    @window = window
  end

  def call
    people_with_dates.map { |person|
      { person: person, upcoming_dates: upcoming_for(person) }
    }.sort_by { |entry| entry[:upcoming_dates].first[:days_until] }
  end

  private

  attr_reader :today, :window

  def people_with_dates
    Person.active.with_upcoming_events.includes(:important_dates)
  end

  def upcoming_for(person)
    person.important_dates
      .map     { |d| [ d, days_until(d) ] }
      .select  { |_, days| days.between?(0, window) }
      .sort_by { |_, days| days }
      .map     { |d, days| date_payload(d, days) }
  end

  def days_until(date)
    target = Date.new(today.year, date.month, date.day)
    target = Date.new(today.year + 1, date.month, date.day) if target < today
    (target - today).to_i
  end

  def date_payload(date, days)
    { name: date.name, month: date.month, day: date.day, days_until: days }
  end
end
