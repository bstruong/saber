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

    it "active excludes voided records" do
      expect(Interaction.active).to include(active_interaction)
      expect(Interaction.active).not_to include(voided_interaction)
    end

    it "voided excludes active records" do
      expect(Interaction.voided).to include(voided_interaction)
      expect(Interaction.voided).not_to include(active_interaction)
    end
  end
end
