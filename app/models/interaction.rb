class Interaction < ApplicationRecord
  belongs_to :person

  scope :active, -> { where(voided_at: nil) }
  scope :voided, -> { where.not(voided_at: nil) }
  scope :recent, -> { where("occurred_at >= ?", Time.current - RECENT_WINDOW) }

  enum :interaction_type, {
    coffee: "coffee",
    lunch:  "lunch",
    text:   "text",
    call:   "call",
    email:  "email",
    event:  "event",
    other:  "other"
  }

  validates :interaction_type, presence: true
  validates :occurred_at,      presence: true

  RECENT_WINDOW = 30.days
end
