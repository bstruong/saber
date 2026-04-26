class SoiScoreCalculator
  RING_SCORE = {
    "board_of_advisors" => 4,
    "network" => 3,
    "community" => 2,
    "audience" => 1,
    "stranger" => 1
  }.freeze

  TWO_WEEKS = 14
  ONE_MONTH = 30
  ONE_QUARTER = 90
  SIX_MONTHS = 180

  def initialize(person)
    @person = person
  end

  def score
    importance + ring_score + value_exchange + interaction_frequency + objective_alignment
  end

  def cadence_days
    case score
    when 17..20 then TWO_WEEKS
    when 13..16 then ONE_MONTH
    when 9..12  then ONE_QUARTER
    else             SIX_MONTHS
    end
  end

  private

  def importance          = @person.importance_score          || 1
  def value_exchange      = @person.value_exchange_score      || 1
  def objective_alignment = @person.objective_alignment_score || 1

  def ring_score
    RING_SCORE[@person.ring] || 1
  end

  def interaction_frequency
    case recent_interaction_count
    when 0    then 1
    when 1..2 then 2
    when 3..5 then 3
    else           4
    end
  end

  def recent_interaction_count
    @person.interactions.where(occurred_at: 6.months.ago..Date.today).count
  end
end
