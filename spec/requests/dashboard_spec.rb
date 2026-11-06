require "rails_helper"

RSpec.describe "Dashboard", type: :request do
  it "renders prospect pulse, SOI queue, and Sunday checklist" do
    create(:contact, :prospect_linkedin, name: "Elena Voss")
    due = create(:contact, :due_for_follow_up, name: "Maya Chen")
    due.update_columns(next_follow_up_due: 1.day.ago)

    get root_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Prospect pulse")
    expect(response.body).to include("SOI follow-up")
    expect(response.body).to include("Sunday checklist")
    expect(response.body).to include("Elena Voss")
    expect(response.body).to include("Maya Chen")
  end
end
