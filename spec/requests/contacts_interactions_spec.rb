require "rails_helper"

RSpec.describe "Contacts and interactions", type: :request do
  let(:contact) { create(:contact, :prospect_linkedin, name: "Elena Voss") }

  it "shows a contact" do
    get contact_path(contact)
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Elena Voss")
  end

  it "logs an interaction and leaves the prospect queue" do
    post contact_interactions_path(contact), params: {
      interaction: {
        interaction_type: "dm",
        hook_em_notes: "Hiring",
        help_em_notes: "One-pager",
        ask_em_notes: "15-min audit"
      }
    }

    expect(response).to redirect_to(contact_path(contact))
    expect(contact.reload.prospect?).to eq(false)
    expect(contact.interactions.count).to eq(1)
  end
end
