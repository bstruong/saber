class Reminder < ApplicationRecord
  belongs_to :person

  scope :active, -> { where(dismissed_at: nil) }

  validates :reason, presence: true
  validates :due_at, presence: true
end
