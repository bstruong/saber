class Interaction < ApplicationRecord
  belongs_to :person

  scope :active, -> { where(voided_at: nil) }
  scope :voided, -> { where.not(voided_at: nil) }

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
end
