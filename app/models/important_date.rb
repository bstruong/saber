class ImportantDate < ApplicationRecord
  belongs_to :person

  validates :name,  presence: true
  validates :month, presence: true, inclusion: { in: 1..12 }
  validates :day,   presence: true, inclusion: { in: 1..31 }
end
