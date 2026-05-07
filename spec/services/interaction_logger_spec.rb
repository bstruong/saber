require "rails_helper"

RSpec.describe InteractionLogger do
  let(:person) { create(:person, last_connected_at: nil) }
  let(:attributes) { { interaction_type: :coffee, occurred_at: Date.today, notes: "caught up" } }

  describe "#call" do
    it "creates an interaction on the person" do
      expect {
        described_class.new(person: person, attributes: attributes).call
      }.to change { person.interactions.count }.by(1)
    end

    it "returns the persisted interaction" do
      result = described_class.new(person: person, attributes: attributes).call
      expect(result).to be_a(Interaction)
      expect(result).to be_persisted
    end

    it "advances last_connected_at when previously nil" do
      described_class.new(person: person, attributes: attributes).call
      expect(person.reload.last_connected_at).to eq(Date.today.in_time_zone.beginning_of_day)
    end

    it "advances last_connected_at to a more recent occurred_at" do
      person.update!(last_connected_at: 10.days.ago.beginning_of_day)
      described_class.new(person: person, attributes: attributes.merge(occurred_at: Date.today)).call
      expect(person.reload.last_connected_at).to eq(Date.today.in_time_zone.beginning_of_day)
    end

    # MAX semantics - backdated entries never move the timestamp backward
    it "leaves last_connected_at alone when occurred_at is earlier than current" do
      original = 1.day.ago.beginning_of_day
      person.update!(last_connected_at: original)
      described_class.new(person: person, attributes: attributes.merge(occurred_at: 10.days.ago.to_date)).call
      expect(person.reload.last_connected_at).to be_within(1.second).of(original)
    end

    it "dismisses the active reminder for this person" do
      reminder = create(:reminder, person: person)
      described_class.new(person: person, attributes: attributes).call
      expect(reminder.reload.dismissed_at).to be_present
    end

    it "does not overwrite an already-dismissed reminder's dismissed_at" do
      old_time = 3.days.ago
      reminder = create(:reminder, person: person, dismissed_at: old_time)
      described_class.new(person: person, attributes: attributes).call
      expect(reminder.reload.dismissed_at).to be_within(1.second).of(old_time)
    end

    it "does not touch reminders on other people" do
      other = create(:person)
      other_reminder = create(:reminder, person: other)
      described_class.new(person: person, attributes: attributes).call
      expect(other_reminder.reload.dismissed_at).to be_nil
    end

    # Pinning decision #3 - interactions do not recompute score/cadence
    it "does not recompute connection_score or cadence_days" do
      person.update_columns(connection_score: 12, cadence_days: 21)
      described_class.new(person: person, attributes: attributes).call
      person.reload
      expect(person.connection_score).to eq(12)
      expect(person.cadence_days).to eq(21)
    end

    it "raises ActiveRecord::RecordInvalid for invalid attributes" do
      expect {
        described_class.new(person: person, attributes: attributes.merge(occurred_at: nil)).call
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "rolls back the interaction when a downstream side effect fails" do
      allow(person).to receive(:update!).and_raise(ActiveRecord::RecordInvalid.new(person))
      expect {
        described_class.new(person: person, attributes: attributes).call rescue nil
      }.not_to change(Interaction, :count)
    end
  end
end
