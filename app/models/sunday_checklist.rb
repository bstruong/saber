class SundayChecklist < ApplicationRecord
  CHECK_ATTRIBUTES = %w[
    answered_no_reply_emails
    cleared_social_dms
    scheduled_ring1_coffee
    sent_ring2_hellos
    followed_up_new_contacts
  ].freeze

  validates :week_of, presence: true, uniqueness: true

  def self.for_current_week
    find_or_create_by!(week_of: Date.current.beginning_of_week(:monday))
  end

  def completed_count
    CHECK_ATTRIBUTES.count { |attr| public_send(attr) }
  end

  def total_count
    CHECK_ATTRIBUTES.size
  end
end
