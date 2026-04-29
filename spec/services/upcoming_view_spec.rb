require "rails_helper"

RSpec.describe UpcomingView do
  let(:today) { Date.new(2026, 7, 15) }

  before { allow(Date).to receive(:today).and_return(today) }

  describe ".call" do
    it "returns persons with upcoming dates in window" do
      person = create(:person)
      create(:important_date, person: person, month: 7, day: 20)
      result = described_class.call
      expect(result.length).to eq(1)
      expect(result.first[:person]).to eq(person)
    end

    it "excludes persons whose dates are outside the window" do
      person = create(:person)
      create(:important_date, person: person, month: 11, day: 1)
      expect(described_class.call).to be_empty
    end

    it "excludes soft-deleted persons" do
      person = create(:person)
      create(:important_date, person: person, month: 7, day: 20)
      person.soft_delete
      expect(described_class.call).to be_empty
    end

    it "shapes each upcoming date with name, month, day, days_until" do
      person = create(:person)
      create(:important_date, person: person, name: "Birthday", month: 7, day: 20)
      result = described_class.call
      expect(result.first[:upcoming_dates]).to eq([
        { name: "Birthday", month: 7, day: 20, days_until: 5 }
      ])
    end

    it "sorts persons by their soonest upcoming date" do
      far  = create(:person, name: "Far")
      near = create(:person, name: "Near")
      create(:important_date, person: far,  month: 8, day: 10)
      create(:important_date, person: near, month: 7, day: 20)
      expect(described_class.call.map { |e| e[:person].name }).to eq([ "Near", "Far" ])
    end
  end
end
