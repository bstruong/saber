FactoryBot.define do
  factory :reminder do
    association :person
    reason { "Haven't caught up in a while" }
    due_at { Date.today }
  end
end
