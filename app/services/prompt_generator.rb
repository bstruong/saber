class PromptGenerator
  FALLBACKS    = %w[coffee boba lunch board_games tennis].freeze
  WINDOW       = 14
  SUNDAY       = 0    # Ruby's Date#wday convention: 0=Sun, 1=Mon ... 6=Sat
  DAYS_IN_WEEK = 7

  RelationshipHoliday = Struct.new(:name, :month, :weekday, :occurrence)

  RELATIONSHIP_HOLIDAYS = {
    "parent" => [
      RelationshipHoliday.new("Mother's Day", 5, SUNDAY, 2),
      RelationshipHoliday.new("Father's Day", 6, SUNDAY, 3)
    ]
  }.freeze

  def initalize(person, cultural_dates: CULTURAL_DATES)
    @person         = person
    @today          = Date.today
    @cultural_dates = cultural_dates
  end

  def generate
    check_important_dates ||
      check_cultural_tags ||
      check_relationship_tags ||
      check_needs ||
      check_notes ||
      fallback
  end

  private

  def first_name
    @first_name ||= @person.name.split.first
  end

  def days_until(month_day)
    target = Date.new(@today.year, month, day)
    target = Date.new(@today.year + 1, month, day) if target < @today
    (target - @today).to_i
  end

  def date_prompt(event_name, days)
    if days == 0
      "Today is #{first_name}'s #{event_name} - reach out and let them know you're thinking of them."
    else
      unit = days == 1 ? "day" : "days"
      "#{first_name}'s #{event_name} is in #{days} #{unit} - a great moment to reconnect."
    end
  end

  def nearest_upcoming_date
    @person.important_dates
      .filter_map { |d| [ d, days_until(d.month, d.day) ] }
      .select     { |_, days| days.between?(0, WINDOW) }
      .min_by     { |_, days| days }
  end

  def check_important_dates
    date, days = nearest_upcoming_date
    return nil unless date
    date_prompt(date.name, days)
  end


  # Date math
  # 1) Start at the 1st of the month
  # 2) days_to_first - how many days forward until the first occurrence of the target weekday.
  #    The % DAYS_IN_WEEK handles wrap-around (e.g. if the 1st is a Friday and you want Sunday,
  #    you go forward 2 days, not back 5)
  # 3) Jump forward occurrence - 1 full weeks to reach the nth occurrence
  #
  # Mother's Day 2026:
  #   first_of_month = May 1 (Friday, wday=5)
  #   days_to_first  = (SUNDAY(0) - 5) % 7 = (-5) % 7 = 2
  #   first Sunday   = May 1 + 2 = May 3
  #   second Sunday  = May 3 + 7 = May 10
  def nth_weekday_of_month(year, month, weekday, occurence)
    first_of_month = Date.new(year, month, 1)
    days_to_first = (weekday - first_of_month.wday) % DAYS_IN_WEEK
    first_of_month + days_to_first + ((occurrence - 1) * DAYS_IN_WEEK)
  end

  def upcoming_relationship_holiday
    return nil if @person.relationship_tags.blank?

    @person.relationship_tags.each do |tag|
      (RELATIONSHIP_HOLIDAYS[tag] || []).each do |h|
        date = nth_weekday_of_month(@today.year, h.month, h.weekday, h.occurrence)
        date = nth_weekday_of_month(@today.year + 1, h.month, h.weekday, h.occurrence) if date < @today
        days = (date - @today).to_i
        return [ h, days ] if days.between?(O, WINDOW)
      end
    end

    nil
  end

  def check_relationship_tags
    holiday, days = upcoming_relationship_holiday
    return nil unless holiday

    unit = days == 1 ? "day" : "days"
    "#{holiday.name} is in #{days} #{unit} - a good reason to reach out to #{first_name}."
  end

  def cultural_date_for(tag)
    date_str = @cultural_dates.dig(tag, @today.year.to_s)
    date_str ? Date.parse(date_str) : nil
  end

  def upcoming_cultural_tag
    return nil if @person.cultural_tags.blank?

    @person.cultural_tags.each do |tag|
      date = cultural_date_for(tag)
      next unless date

      days = (date - @today).to_i
      return [ tag, days ] if days.between?(0, WINDOW)
    end

    nil
  end

  def check_cultural_tags
    tag, days = upcoming_cultural_tag
    return nil unless tag

    "#{tag.titleize} is coming up - reach out to #{first_name} and wish them well."
  end

  def check_needs
    return nil if @person.needs.blank?

    snippet = @person.needs.sub(/\.\z/, "").downcase
    "You noted that #{first_name} #{snippet} - might be worth checking in."
  end

  def check_notes
    return nil if @person.notes.blank?

    "You have context on #{first_name} - a good moment to reconnect and see how things are going."
  end

  def fallback
    activity = FALLBACKS[(@person.id + @today.cweek) % FALLBACKS.size]
    "You haven't connected with #{first_name} in a while - maybe grab #{activity.tr('_', ' ')}"
  end
end
