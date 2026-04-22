FactoryBot.define do
  factory :interaction do
    association :person
    interaction_type { :coffee }
    occurred_at      { Date.today }
  end
end
