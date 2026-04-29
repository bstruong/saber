require "rails_helper"

RSpec.describe "Api::People", type: :request do
  let!(:person) { create(:person) }

  describe "GET /api/people" do
    it "returns all active people" do
      get "/api/people"
      expect(response).to have_http_status(:ok)
      expect(json_body.length).to eq(1)
    end

    it "excludes soft-deleted people" do
      person.soft_delete
      get "/api/people"
      expect(json_body).to be_empty
    end

    it "filters by ring" do
      create(:person, name: "Stranger", ring: :stranger)
      get "/api/people", params: { ring: "network" }
      expect(json_body.pluck("ring").uniq).to eq([ "network" ])
    end

    it "filters by needs_reconnection" do
      overdue = create(:person, name: "Overdue", ring: :network, last_connected_at: 200.days.ago)
      overdue.update_columns(cadence_days: 90)
      get "/api/people", params: { needs_reconnection: "true" }
      expect(json_body.pluck("id")).to include(overdue.id)
    end

    it "filters by upcoming_events" do
      soon = Date.today + 5
      create(:important_date, person: person, month: soon.month, day: soon.day)
      get "/api/people", params: { upcoming_events: "true" }
      expect(json_body.pluck("id")).to include(person.id)
    end
  end

  describe "GET /api/people/:id" do
    it "returns the person" do
      get "/api/people/#{person.id}"
      expect(response).to have_http_status(:ok)
      expect(json_body["name"]).to eq(person.name)
    end

    it "returns 404 for unknown id" do
      get "/api/people/0"
      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 for soft-deleted person" do
      person.soft_delete
      get "/api/people/#{person.id}"
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /api/people" do
    let(:valid_params) do
      {
        person: {
          name:                "Jamie Doe",
          ring:                "network",
          importance_score:    3,
          reciprocity_score:   2,
          shared_values_score: 2
        }
      }
    end

    it "creates a person and computes connection_score" do
      post "/api/people", params: valid_params
      expect(response).to have_http_status(:created)
      expect(json_body["connection_score"]).to be_present
    end

    it "returns 422 for invalid params" do
      post "/api/people", params: { person: { name: "", ring: "network" } }
      expect(response).to have_http_status(:unprocessable_content)
      expect(json_body["errors"]).to be_present
    end
  end

  describe "PATCH /api/people/:id" do
    it "updates the person" do
      patch "/api/people/#{person.id}", params: { person: { name: "Updated Name" } }
      expect(response).to have_http_status(:ok)
      expect(json_body["name"]).to eq("Updated Name")
    end
  end

  describe "DELETE /api/people/:id" do
    it "soft deletes the person" do
      delete "/api/people/#{person.id}"
      expect(response).to have_http_status(:no_content)
      expect(person.reload.deleted_at).to be_present
    end
  end
end
