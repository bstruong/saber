class Interaction < ApplicationRecord
  belongs_to :person

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
