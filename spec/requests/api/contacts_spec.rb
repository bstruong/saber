require "rails_helper"

RSpec.describe "Api::Contacts", type: :request do
  let!(:person) { create(:person) }

  describe "GET /api/contacts" do
    it "returns all active contacts" do
      get "/api/contacts"
      expect(response).to have_http_status(:ok)
      expect(json_body.length).to eq(1)
    end

    it "excludes soft-deleted contacts" do
      person.soft_delete
      get "/api/contacts"
      expect(json_body).to be_empty
    end

    it "filters by ring" do
      create(:person, name: "Stranger", ring: :stranger)
      get "/api/contacts", params: { ring: "network" }
      expect(json_body.pluck("ring").uniq).to eq([ "network" ])
    end

    it "filters by needs_reconnection" do
      overdue = create(:person, name: "Overdue", ring: :network, last_contacted_at: 200.days.ago)
      overdue.update_columns(cadence_days: 90)
      get "/api/contacts", params: { needs_reconnection: "true" }
      expect(json_body.pluck("id")).to include(overdue.id)
    end

    it "filters by upcoming_events" do
      soon = Date.today + 5
      create(:important_date, person: person, month: soon.month, day: soon.day)
      get "/api/contacts", params: { upcoming_events: "true" }
      expect(json_body.pluck("id")).to include(person.id)
    end
  end

  describe "GET /api/contacts/:id" do
    it "returns the contact" do
      get "/api/contacts/#{person.id}"
      expect(response).to have_http_status(:ok)
      expect(json_body["name"]).to eq(person.name)
    end

    it "returns 404 for unknown id" do
      get "/api/contacts/0"
      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 for soft-deleted contact" do
      person.soft_delete
      get "/api/contacts/#{person.id}"
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /api/contacts" do
    let(:valid_params) do
      {
        person: {
          name:                      "Jamie Doe",
          ring:                      "network",
          importance_score:          3,
          value_exchange_score:      2,
          objective_alignment_score: 2
        }
      }
    end

    it "creates a contact and computes soi_score" do
      post "/api/contacts", params: valid_params
      expect(response).to have_http_status(:created)
      expect(json_body["soi_score"]).to be_present
    end

    it "returns 422 for invalid params" do
      post "/api/contacts", params: { person: { name: "", ring: "network" } }
      expect(response).to have_http_status(:unprocessable_content)
      expect(json_body["errors"]).to be_present
    end
  end

  describe "PATCH /api/contacts/:id" do
    it "updates the contact" do
      patch "/api/contacts/#{person.id}", params: { person: { name: "Updated Name" } }
      expect(response).to have_http_status(:ok)
      expect(json_body["name"]).to eq("Updated Name")
    end
  end

  describe "DELETE /api/contacts/:id" do
    it "soft deletes the contact" do
      delete "/api/contacts/#{person.id}"
      expect(response).to have_http_status(:no_content)
      expect(person.reload.deleted_at).to be_present
    end
  end
end
