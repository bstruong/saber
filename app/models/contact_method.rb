class ContactMethod < ApplicationRecord
  belongs_to :person

  enum :method_type, {
    linkedin:  "linkedin",
    email:     "email",
    phone:     "phone",
    twitter:   "twitter",
    instagram: "instagram",
    other:     "other"
  }

  validates :method_type, presence: true
  validates :value,       presence: true
end
