FactoryBot.define do
  factory :contact_method do
    association :person
    method_type { :email }
    value       { "alex@example.com" }
  end
end
