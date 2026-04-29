require "rails_helper"

RSpec.describe "Api::Reminders", type: :request do
  let(:reminder) { create(:reminder) }

  describe "POST /api/reminders/:id/dismiss" do
    it "sets dismissed_at and returns the reminder" do
      post "/api/reminders/#{reminder.id}/dismiss"
      expect(response).to have_http_status(:ok)
      expect(json_body["dismissed_at"]).to be_present
      expect(reminder.reload.dismissed_at).to be_present
    end

    it "returns whitelisted reminder fields only" do
      post "/api/reminders/#{reminder.id}/dismiss"
      expect(json_body.keys).to match_array(%w[id due_at reason snoozed_until dismissed_at])
    end

    it "returns 404 for unknown reminder" do
      post "/api/reminders/0/dismiss"
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /api/reminders/:id/snooze" do
    let(:snooze_until) { (Date.today + 7).iso8601 }

    it "sets snoozed_until and returns the reminder" do
      post "/api/reminders/#{reminder.id}/snooze", params: { snoozed_until: snooze_until }
      expect(response).to have_http_status(:ok)
      expect(json_body["snoozed_until"]).to eq(snooze_until)
      expect(reminder.reload.snoozed_until).to eq(Date.parse(snooze_until))
    end

    it "returns 400 when snoozed_until is missing" do
      post "/api/reminders/#{reminder.id}/snooze"
      expect(response).to have_http_status(:bad_request)
    end

    it "returns 404 for unknown reminder" do
      post "/api/reminders/0/snooze", params: { snoozed_until: snooze_until }
      expect(response).to have_http_status(:not_found)
    end
  end
end
