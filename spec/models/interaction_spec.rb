require "rails_helper"

RSpec.describe Interaction, type: :model do
  describe "validations" do
    it { should validate_presence_of(:interaction_type) }
    it { should validate_presence_of(:occurred_at) }
  end

  describe "scopes" do
    let(:person) { create(:person) }
    let!(:active_interaction) { create(:interaction, person: person) }
    let!(:voided_interaction) { create(:interaction, person: person, voided_at: Time.current) }
    let!(:recent_interaction) { create(:interaction, person: person, occurred_at: Time.current - Interaction::RECENT_WINDOW) }
    let!(:not_recent_interaction) { create(:interaction, person: person, occurred_at: Time.current - Interaction::RECENT_WINDOW - 1.day) }

    it "active excludes voided records" do
      expect(Interaction.active).to include(active_interaction)
      expect(Interaction.active).not_to include(voided_interaction)
    end

    it "voided excludes active records" do
      expect(Interaction.voided).to include(voided_interaction)
      expect(Interaction.voided).not_to include(active_interaction)
    end

    it "recent includes recent records" do
      expect(Interaction.recent).to include(recent_interaction)
      expect(Interaction.recent).not_to include(not_recent_interaction)
    end

    it "recent excludes not recent records" do
      expect(Interaction.recent).not_to include(not_recent_interaction)
    end
  end
end
