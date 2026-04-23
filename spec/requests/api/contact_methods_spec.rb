require "rails_helper"

RSpec.describe "Api::ContactMethods", type: :request do
  let!(:person) { create(:person) }

  describe "POST /api/contacts/:contact_id/contact_methods" do
    let(:valid_params) { { contact_method: { method_type: "phone", value: "415-555-0100" } } }

    it "creates a contact method" do
      post "/api/contacts/#{person.id}/contact_methods", params: valid_params
      expect(response).to have_http_status(:created)
      expect(json_body["method_type"]).to eq("phone")
      expect(json_body["value"]).to eq("415-555-0100")
    end

    it "returns 422 for missing value" do
      post "/api/contacts/#{person.id}/contact_methods",
        params: { contact_method: { method_type: "phone", value: "" } }
      expect(response).to have_http_status(:unprocessable_content)
    end

    it "returns 404 for soft-deleted contact" do
      person.soft_delete
      post "/api/contacts/#{person.id}/contact_methods", params: valid_params
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE /api/contacts/:contact_id/contact_methods/:id" do
    let!(:contact_method) { person.contact_methods.first }

    it "destroys the contact method" do
      delete "/api/contacts/#{person.id}/contact_methods/#{contact_method.id}"
      expect(response).to have_http_status(:no_content)
      expect { contact_method.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  private

  def json_body
    JSON.parse(response.body)
  end
end
