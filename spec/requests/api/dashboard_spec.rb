require "rails_helper"

RSpec.describe "Api::Dashboard", type: :request do
  describe "GET /api/dashboard/reconnect" do
    it "returns active reminders" do
      reminder = create(:reminder)
      get "/api/dashboard/reconnect"
      expect(response).to have_http_status(:ok)
      expect(json_body.length).to eq(1)
      expect(json_body.first["id"]).to eq(reminder.id)
    end

    it "excludes dismissed reminders" do
      create(:reminder, dismissed_at: Time.current)
      get "/api/dashboard/reconnect"
      expect(json_body).to be_empty
    end

    it "excludes reminders snoozed past today" do
      create(:reminder, snoozed_until: Date.today + 3)
      get "/api/dashboard/reconnect"
      expect(json_body).to be_empty
    end

    it "includes reminders whose snooze has expired" do
      create(:reminder, snoozed_until: Date.today - 1)
      get "/api/dashboard/reconnect"
      expect(json_body.length).to eq(1)
    end

    it "sorts reminders by due_at ascending" do
      late  = create(:reminder, due_at: Date.today)
      early = create(:reminder, due_at: Date.today - 5)
      get "/api/dashboard/reconnect"
      expect(json_body.pluck("id")).to eq([ early.id, late.id ])
    end

    it "nests person with whitelisted fields only" do
      person = create(:person, name: "Sam Lee", ring: :network)
      create(:reminder, person: person)
      get "/api/dashboard/reconnect"
      expect(json_body.first["person"].keys).to match_array(%w[id name ring last_connected_at])
    end
  end

  describe "GET /api/dashboard/upcoming" do
    before { allow(Date).to receive(:today).and_return(Date.new(2026, 7, 15)) }

    it "returns persons with upcoming dates" do
      person = create(:person)
      create(:important_date, person: person, month: 7, day: 20)
      get "/api/dashboard/upcoming"
      expect(response).to have_http_status(:ok)
      expect(json_body.length).to eq(1)
    end

    it "nests person with whitelisted fields and shaped upcoming_dates" do
      person = create(:person, name: "Sam Lee")
      create(:important_date, person: person, name: "Birthday", month: 7, day: 20)
      get "/api/dashboard/upcoming"
      entry = json_body.first
      expect(entry["person"].keys).to match_array(%w[id name ring last_connected_at])
      expect(entry["upcoming_dates"].first).to include(
        "name" => "Birthday", "month" => 7, "day" => 20, "days_until" => 5
      )
    end

    it "sorts entries by soonest upcoming date" do
      far  = create(:person, name: "Far")
      near = create(:person, name: "Near")
      create(:important_date, person: far,  month: 8, day: 10)
      create(:important_date, person: near, month: 7, day: 20)
      get "/api/dashboard/upcoming"
      expect(json_body.map { |e| e["person"]["name"] }).to eq([ "Near", "Far" ])
    end
  end
end
