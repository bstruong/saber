class Interaction < ApplicationRecord
  TYPES = %w[
    dm
    cold_email
    cold_call
    audit_call_15min
    meetup_chat
    sunday_checkin
  ].freeze

  belongs_to :contact

  enum :interaction_type, TYPES.index_by(&:itself), validate: true

  validates :interaction_type, presence: true
end
