FactoryBot.define do
  factory :person do
    name { "Alex Chen" }
    ring { :network }

    after(:create) do |person|
      create(:contact_method, person: person)
    end
  end
end
