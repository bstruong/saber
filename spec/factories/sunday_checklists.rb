FactoryBot.define do
  factory :sunday_checklist do
    week_of { Date.current.beginning_of_week(:monday) }
    answered_no_reply_emails { false }
    cleared_social_dms { false }
    scheduled_ring1_coffee { false }
    sent_ring2_hellos { false }
    followed_up_new_contacts { false }
  end
end
