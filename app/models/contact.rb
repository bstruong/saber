class Contact < ApplicationRecord
  SOURCES = %w[
    linkedin
    work_at_a_startup
    sf_ruby_meetup
    sf_incubator
    indie_hackers
    direct_referral
  ].freeze

  PROSPECT_SOURCES = %w[linkedin work_at_a_startup].freeze

  SOI_RINGS = %w[
    board_of_advisors
    network
    community
    audience
    strangers
  ].freeze

  FOLLOW_UP_FREQUENCIES = %w[weekly monthly quarterly semi_annual].freeze

  SCORECARD_ATTRIBUTES = %w[
    goal_importance
    ring_level
    value_exchange
    past_interaction_freq
    objective_alignment
  ].freeze

  has_many :interactions, dependent: :destroy

  enum :source, SOURCES.index_by(&:itself), validate: true
  enum :soi_ring, SOI_RINGS.index_by(&:itself), validate: true
  enum :follow_up_frequency, FOLLOW_UP_FREQUENCIES.index_by(&:itself), allow_nil: true, validate: { allow_nil: true }

  validates :name, presence: true
  validates :goal_importance, :ring_level, :value_exchange,
            :past_interaction_freq, :objective_alignment,
            inclusion: { in: 1..4 }

  before_validation :recalculate_scorecard, if: :scorecard_inputs_changed?

  scope :prospects, -> {
    where(source: PROSPECT_SOURCES, last_contacted_at: nil)
      .order(created_at: :desc)
  }

  scope :follow_up_due, -> {
    where.not(last_contacted_at: nil)
      .where("next_follow_up_due <= ?", Time.current)
      .order(:next_follow_up_due)
  }

  def prospect?
    PROSPECT_SOURCES.include?(source) && last_contacted_at.nil?
  end

  def recalculate_scorecard!
    ScorecardCalculator.new(self).apply!
  end

  private

  def scorecard_inputs_changed?
    SCORECARD_ATTRIBUTES.any? { |attr| will_save_change_to_attribute?(attr) } ||
      will_save_change_to_soi_ring? ||
      will_save_change_to_last_contacted_at? ||
      new_record?
  end

  def recalculate_scorecard
    ScorecardCalculator.new(self).apply_to_record
  end
end
