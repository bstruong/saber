require "rails_helper"

RSpec.describe DriftDetector do
  # Stub generator — outgoing query, returns a fixed prompt
  let(:fake_generator) do
    Class.new do
      def initialize(person); @person = person; end
      def generate; "fake prompt for #{@person.name}"; end
    end
  end

  describe ".call" do
    it "creates an active reminder for a drifted person" do
      person = create(:person, last_contacted_at: nil)
      expect {
        described_class.new(generator: fake_generator).call
      }.to change { person.reminders.active.count }.by(1)
    end

    it "uses the injected generator for the reminder reason" do
      person = create(:person, name: "Alex Chen", last_contacted_at: nil)
      described_class.new(generator: fake_generator).call
      expect(person.reminders.last.reason).to eq("fake prompt for Alex Chen")
    end

    it "sets due_at to today" do
      create(:person, last_contacted_at: nil)
      described_class.new(generator: fake_generator).call
      expect(Reminder.last.due_at).to eq(Date.today)
    end

    it "is idempotent — does not create a duplicate active reminder" do
      create(:person, last_contacted_at: nil)
      described_class.new(generator: fake_generator).call
      expect {
        described_class.new(generator: fake_generator).call
      }.not_to change(Reminder, :count)
    end

    it "treats a snoozed reminder as still active and skips it" do
      person = create(:person, last_contacted_at: nil)
      create(:reminder, person: person, snoozed_until: Date.today + 7)
      expect {
        described_class.new(generator: fake_generator).call
      }.not_to change(Reminder, :count)
    end

    it "creates a new reminder if the previous one was dismissed" do
      person = create(:person, last_contacted_at: nil)
      create(:reminder, person: person, dismissed_at: Time.current)
      expect {
        described_class.new(generator: fake_generator).call
      }.to change { person.reminders.active.count }.by(1)
    end

    it "skips people not needing reconnection" do
      person = create(:person, last_contacted_at: 1.day.ago)
      person.update_columns(cadence_days: 90)
      expect {
        described_class.new(generator: fake_generator).call
      }.not_to change(Reminder, :count)
    end

    it "skips soft-deleted people" do
      person = create(:person, last_contacted_at: nil)
      person.soft_delete
      expect {
        described_class.new(generator: fake_generator).call
      }.not_to change(Reminder, :count)
    end
  end
end
