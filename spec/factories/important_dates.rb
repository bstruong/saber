FactoryBot.define do
  factory :important_date do
    association :person
    name  { "Birthday" }
    month { 6 }
    day   { 15 }
  end
end
