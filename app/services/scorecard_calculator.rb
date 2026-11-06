class ScorecardCalculator
  FREQUENCY_DAYS = {
    "weekly" => 7,
    "monthly" => 30,
    "quarterly" => 90,
    "semi_annual" => 180
  }.freeze

  def initialize(contact)
    @contact = contact
  end

  def score
    Contact::SCORECARD_ATTRIBUTES.sum { |attr| @contact.public_send(attr).to_i }
  end

  def follow_up_frequency
    case score
    when 17..20 then "weekly"
    when 13..16 then "monthly"
    when 9..12  then "quarterly"
    else             "semi_annual"
    end
  end

  def next_follow_up_due
    anchor = @contact.last_contacted_at || Time.current
    anchor + FREQUENCY_DAYS.fetch(follow_up_frequency).days
  end

  def apply_to_record
    @contact.total_score = score
    @contact.follow_up_frequency = follow_up_frequency
    @contact.next_follow_up_due = next_follow_up_due
  end

  def apply!
    apply_to_record
    @contact.save!
  end
end
