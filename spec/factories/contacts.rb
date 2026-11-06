FactoryBot.define do
  factory :contact do
    sequence(:name) { |n| "Contact #{n}" }
    company { "Example Co" }
    source { "direct_referral" }
    soi_ring { "network" }
    goal_importance { 3 }
    ring_level { 3 }
    value_exchange { 3 }
    past_interaction_freq { 2 }
    objective_alignment { 3 }
    last_contacted_at { 5.days.ago }

    trait :prospect_linkedin do
      source { "linkedin" }
      soi_ring { "strangers" }
      last_contacted_at { nil }
      profile_url { "https://www.linkedin.com/in/example" }
      goal_importance { 1 }
      ring_level { 1 }
      value_exchange { 1 }
      past_interaction_freq { 1 }
      objective_alignment { 1 }
    end

    trait :prospect_waas do
      source { "work_at_a_startup" }
      soi_ring { "strangers" }
      last_contacted_at { nil }
      profile_url { "https://www.workatastartup.com/companies/example" }
      goal_importance { 1 }
      ring_level { 1 }
      value_exchange { 1 }
      past_interaction_freq { 1 }
      objective_alignment { 1 }
    end

    trait :due_for_follow_up do
      last_contacted_at { 40.days.ago }
      goal_importance { 4 }
      ring_level { 4 }
      value_exchange { 4 }
      past_interaction_freq { 4 }
      objective_alignment { 4 }
    end
  end
end
