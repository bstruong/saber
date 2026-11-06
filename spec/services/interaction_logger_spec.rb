require "rails_helper"

RSpec.describe InteractionLogger do
  let(:contact) { create(:contact, :prospect_linkedin) }

  it "creates an interaction and advances last_contacted_at" do
    expect {
      described_class.call(
        contact:,
        attrs: {
          interaction_type: "dm",
          hook_em_notes: "Hook",
          help_em_notes: "Help",
          ask_em_notes: "Ask"
        }
      )
    }.to change(Interaction, :count).by(1)

    contact.reload
    expect(contact.last_contacted_at).to be_present
    expect(contact.prospect?).to eq(false)
    expect(contact.next_follow_up_due).to be_present
  end
end
