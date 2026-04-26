class Person < ApplicationRecord
  has_many :contact_methods, dependent: :destroy
  has_many :important_dates, dependent: :destroy
  has_many :interactions,    dependent: :destroy
  has_many :reminders,       dependent: :destroy

  enum :ring, {
    board_of_advisors: "board_of_advisors",
    network:           "network",
    community:         "community",
    audience:          "audience",
    stranger:          "stranger"
  }

  enum :score_source, {
    computed: "computed",
    manual:   "manual"
  }

  UPCOMING_DAYS_WINDOW = 30
  SCORE_DIMENSIONS = %i[ring importance_score value_exchange_score objective_alignment_score].freeze

  scope :active,  -> { where(deleted_at: nil) }
  scope :deleted, -> { where.not(deleted_at: nil) }

  scope :with_upcoming_events, -> {
    today = Date.today
    upcoming = (today...(today + UPCOMING_DAYS_WINDOW)).map { |d| [ d.month, d.day ] }
    placeholders = upcoming.map { "(?, ?)" }.join(", ")
    joins(:important_dates)
      .where("(important_dates.month, important_dates.day) IN (#{placeholders})", *upcoming.flatten)
      .distinct
  }

  scope :needs_reconnection, -> {
    where(
      "last_contacted_at IS NULL OR (" \
      "COALESCE(cadence_override_days, cadence_days) IS NOT NULL AND " \
      "last_contacted_at + (COALESCE(cadence_override_days, cadence_days) || ' days')::interval < NOW())"
    )
  }

  validates :name,  presence: true
  validates :ring,  presence: true

  before_save :compute_soi_score, if: :should_compute_score?

  def soft_delete
    update!(deleted_at: Time.current)
  end

  def effective_cadence
    cadence_override_days || cadence_days
  end

  private

  def should_compute_score?
    # skip if user has taken manual control, or if no dimension changed (avoids redundant recomputation on unrelated saves)
    computed? && SCORE_DIMENSIONS.any? { |a| will_save_change_to_attribute?(a) }
  end

  def compute_soi_score
    calc = SoiScoreCalculator.new(self)
    self.soi_score    = calc.score
    self.cadence_days = calc.cadence_days
  end
end
