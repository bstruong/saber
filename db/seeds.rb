# frozen_string_literal: true

user = User.find_or_initialize_by(email: "owner@ikigai.local")
user.password = "password123"
user.password_confirmation = "password123"
user.save!

elena = Contact.find_or_initialize_by(email: "elena@parcelkit.example")
elena.assign_attributes(
  name: "Elena Voss",
  company: "Parcelkit",
  profile_url: "https://www.linkedin.com/in/elena-voss",
  source: "linkedin",
  soi_ring: "strangers",
  goal_importance: 2,
  ring_level: 1,
  value_exchange: 2,
  past_interaction_freq: 1,
  objective_alignment: 3,
  notes: "Hiring first eng; shipping waitlist for freight ops",
  last_contacted_at: nil
)
elena.save!

chris = Contact.find_or_initialize_by(name: "Chris Park", company: "Monad Health")
chris.assign_attributes(
  profile_url: "https://www.workatastartup.com/companies/monad",
  source: "work_at_a_startup",
  soi_ring: "strangers",
  goal_importance: 1,
  ring_level: 1,
  value_exchange: 1,
  past_interaction_freq: 1,
  objective_alignment: 2,
  notes: "YC W26 · looking for technical co-builder on claims",
  last_contacted_at: nil
)
chris.save!

maya = Contact.find_or_initialize_by(email: "maya@harborlabs.example")
maya.assign_attributes(
  name: "Maya Chen",
  company: "Harbor Labs",
  source: "sf_ruby_meetup",
  soi_ring: "network",
  goal_importance: 4,
  ring_level: 3,
  value_exchange: 4,
  past_interaction_freq: 3,
  objective_alignment: 4,
  last_contacted_at: 8.days.ago,
  notes: "Met at SF Ruby"
)
maya.save!

priya = Contact.find_or_initialize_by(name: "Priya Nair")
priya.assign_attributes(
  company: "Advisor",
  source: "direct_referral",
  soi_ring: "board_of_advisors",
  goal_importance: 4,
  ring_level: 4,
  value_exchange: 4,
  past_interaction_freq: 3,
  objective_alignment: 4,
  last_contacted_at: 10.days.ago
)
priya.save!

unless maya.interactions.exists?
  InteractionLogger.call(
    contact: maya,
    attrs: {
      interaction_type: "meetup_chat",
      hook_em_notes: "Hiring post",
      help_em_notes: "Shared Rails auth notes",
      ask_em_notes: "Coffee next week"
    }
  )
end

SundayChecklist.for_current_week.update!(
  answered_no_reply_emails: true,
  cleared_social_dms: true
)

puts "Seeded Ikigai CRM. Sign in as owner@ikigai.local / password123"
