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

  scope :active,  -> { where(deleted_at: nil) }
  scope :deleted, -> { where.not(deleted_at: nil) }

  validates :name,  presence: true
  validates :ring,  presence: true

  before_save :compute_soi_score, if: :should_compute_score?

  DEFAULT_CADENCE_DAYS = 180 # floor cadence - score out of expected range

  CADENCE_MAP = [
    [ 17..20, 14  ],  # weekly-ish - top tier contacts
    [ 13..16, 30  ],  # monthly - strong network
    [ 9..12,  90  ],  # quarterly- solid but lighter touch
    [ 5..8,   180 ]   # biannual - peripheral relationships
  ].freeze

  def soft_delete
    update!(deleted_at: Time.current)
  end

  def ring_score
    { "board_of_advisors" => 4, "network" => 3, "community" => 2, "audience" => 1, "stranger" => 1 }[ring]
  end

  def interaction_frequency_score
    count = interactions.where(occurred_at: 6.months.ago..Date.today).count
    case count
    when 0    then 1
    when 1..2 then 2
    when 3..5 then 3
    else           4
    end
  end

  def effective_cadence
    cadence_override_days || cadence_days
  end

  private

  def should_compute_score?
    # skip if user has taken manual control, or if no dimension changed (avoids redundant recomputation on unrelated saves)
    computed? && [ :ring, :importance_score, :value_exchange_score, :objective_alignment_score ].any? { |a| will_save_change_to_attribute?(a) }
  end

  def compute_soi_score
    dim1 = importance_score            || 1
    dim2 = ring_score                  || 1
    dim3 = value_exchange_score        || 1
    dim4 = interaction_frequency_score || 1
    dim5 = objective_alignment_score   || 1

    self.soi_score = dim1 + dim2 + dim3 + dim4 + dim5
    self.cadence_days = CADENCE_MAP.find { |range, _| range.cover?(soi_score) }&.last || DEFAULT_CADENCE_DAYS
  end
end
