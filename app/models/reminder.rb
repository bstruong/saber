class Reminder < ApplicationRecord
  belongs_to :person

  scope :active, -> { where(dismissed_at: nil) }
  scope :not_snoozed, -> { where("snoozed_until IS NULL OR snoozed_until <= ?", Date.today) }

  validates :reason, presence: true
  validates :due_at, presence: true
end
