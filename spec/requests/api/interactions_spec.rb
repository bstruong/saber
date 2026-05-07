require "rails_helper"

RSpec.describe "Api::Interactions", type: :request do
  let!(:person) { create(:person) }

  describe "GET /api/people/:person_id/interactions" do
    let!(:interaction) { create(:interaction, person: person) }

    it "returns the person's interactions" do
      get "/api/people/#{person.id}/interactions"
      expect(response).to have_http_status(:ok)
      expect(json_body.length).to eq(1)
    end

    it "excludes interactions from other people" do
      other = create(:person)
      create(:interaction, person: other)
      get "/api/people/#{person.id}/interactions"
      expect(json_body.length).to eq(1)
    end

    it "excludes voided interactions" do
      create(:interaction, person: person, voided_at: Time.current)
      get "/api/people/#{person.id}/interactions"
      expect(json_body.pluck("id")).to eq([ interaction.id ])
    end

    it "returns 404 for unknown person" do
      get "/api/people/0/interactions"
      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 for soft-deleted person" do
      person.soft_delete
      get "/api/people/#{person.id}/interactions"
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /api/people/:person_id/interactions/:id" do
    let!(:interaction) { create(:interaction, person: person) }

    it "returns the interaction" do
      get "/api/people/#{person.id}/interactions/#{interaction.id}"
      expect(response).to have_http_status(:ok)
      expect(json_body["id"]).to eq(interaction.id)
    end

    it "returns 404 for unknown id" do
      get "/api/people/#{person.id}/interactions/0"
      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 when interaction belongs to a different person" do
      other = create(:person)
      get "/api/people/#{other.id}/interactions/#{interaction.id}"
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /api/people/:person_id/interactions" do
    let(:valid_params) do
      { interaction: { interaction_type: "coffee", occurred_at: Date.today.iso8601, notes: "caught up" } }
    end

    it "creates the interaction" do
      expect {
        post "/api/people/#{person.id}/interactions", params: valid_params
      }.to change { person.interactions.count }.by(1)
      expect(response).to have_http_status(:created)
    end

    it "advances last_connected_at on the person" do
      post "/api/people/#{person.id}/interactions", params: valid_params
      expect(person.reload.last_connected_at).to be_present
    end

    it "dismisses the active reminder" do
      reminder = create(:reminder, person: person)
      post "/api/people/#{person.id}/interactions", params: valid_params
      expect(reminder.reload.dismissed_at).to be_present
    end

    it "returns 422 for invalid params" do
      post "/api/people/#{person.id}/interactions", params: { interaction: { interaction_type: "coffee" } }
      expect(response).to have_http_status(:unprocessable_content)
      expect(json_body["errors"]).to be_present
    end

    it "returns 404 for unknown person" do
      post "/api/people/0/interactions", params: valid_params
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /api/people/:person_id/interactions/:id/void" do
    let!(:interaction) { create(:interaction, person: person) }

    it "sets voided_at" do
      post "/api/people/#{person.id}/interactions/#{interaction.id}/void"
      expect(response).to have_http_status(:ok)
      expect(interaction.reload.voided_at).to be_present
    end

    it "removes the interaction from the index" do
      post "/api/people/#{person.id}/interactions/#{interaction.id}/void"
      get "/api/people/#{person.id}/interactions"
      expect(json_body.pluck("id")).not_to include(interaction.id)
    end

    it "returns 404 for unknown interaction id" do
      post "/api/people/#{person.id}/interactions/0/void"
      expect(response).to have_http_status(:not_found)
    end
  end
end
