FactoryBot.define do
  factory :interaction do
    contact
    interaction_type { "dm" }
    hook_em_notes { "Saw a post" }
    help_em_notes { "Shared a note" }
    ask_em_notes { "Asked for a call" }
  end
end
