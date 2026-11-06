require "rails_helper"

RSpec.describe "Prospecting", type: :request do
  it "renders the prospecting page" do
    get prospecting_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Prospecting")
    expect(response.body).to include("LinkedIn")
    expect(response.body).to include("Work at a Startup")
  end

  it "captures a prospect into the queue" do
    expect {
      post contacts_path, params: {
        prospect: "1",
        contact: {
          name: "Aisha Rahman",
          company: "Northline",
          source: "linkedin",
          profile_url: "https://www.linkedin.com/in/aisha",
          hook: "Ops pain into MVP"
        }
      }
    }.to change(Contact, :count).by(1)

    expect(response).to redirect_to(prospecting_path)
    expect(Contact.last).to be_prospect
  end
end
