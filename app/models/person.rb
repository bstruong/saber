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

  validates :name, presence: true
  validates :ring,  presence: true
end
