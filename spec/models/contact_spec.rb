require "rails_helper"

RSpec.describe Contact, type: :model do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to have_many(:interactions).dependent(:destroy) }

  describe ".prospects" do
    it "includes uncontacted LinkedIn and WAAS contacts only" do
      linkedin = create(:contact, :prospect_linkedin)
      waas = create(:contact, :prospect_waas)
      create(:contact, source: "linkedin", last_contacted_at: 1.day.ago)
      create(:contact)

      expect(described_class.prospects).to contain_exactly(linkedin, waas)
    end
  end

  describe ".follow_up_due" do
    it "returns contacted people whose next due is past" do
      due = create(:contact, :due_for_follow_up)
      due.update_columns(next_follow_up_due: 1.day.ago)
      create(:contact, :prospect_linkedin)

      expect(described_class.follow_up_due).to contain_exactly(due)
    end
  end
end
