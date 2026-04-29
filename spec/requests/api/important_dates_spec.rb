require "rails_helper"

RSpec.describe "Api::ImportantDates", type: :request do
  let!(:person) { create(:person) }

  describe "POST /api/people/:person_id/important_dates" do
    let(:valid_params) { { important_date: { name: "Birthday", month: 6, day: 15 } } }

    it "creates an important date" do
      post "/api/people/#{person.id}/important_dates", params: valid_params
      expect(response).to have_http_status(:created)
      expect(json_body["name"]).to eq("Birthday")
      expect(json_body["month"]).to eq(6)
    end

    it "returns 422 for invalid month" do
      post "/api/people/#{person.id}/important_dates",
        params: { important_date: { name: "Birthday", month: 13, day: 1 } }
      expect(response).to have_http_status(:unprocessable_content)
    end

    it "returns 404 for soft-deleted person" do
      person.soft_delete
      post "/api/people/#{person.id}/important_dates", params: valid_params
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE /api/people/:person_id/important_dates/:id" do
    let!(:important_date) { create(:important_date, person: person) }

    it "destroys the important date" do
      delete "/api/people/#{person.id}/important_dates/#{important_date.id}"
      expect(response).to have_http_status(:no_content)
      expect { important_date.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
