require "rails_helper"

RSpec.describe Reminder, type: :model do
  describe "#snoozed?" do
    let(:person) { create(:person) }
    let(:active_reminder) { create(:reminder, person: person) }
    let(:expired_reminder) { create(:reminder, person: person, snoozed_until: Date.yesterday) }
    let(:snoozed_reminder) { create(:reminder, person: person, snoozed_until: Date.today + 1.day) }

    it "returns false for active reminders" do
      expect(active_reminder.snoozed?).to be false
    end

    it "returns false for reminders that are not snoozed" do
      expect(expired_reminder.snoozed?).to be false
    end

    it "returns true for reminders that are snoozed" do
      expect(snoozed_reminder.snoozed?).to be true
    end
  end
end
