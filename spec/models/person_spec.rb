require "rails_helper"

RSpec.describe Person, type: :model do
  describe "associations" do
    it { should have_many(:contact_methods).dependent(:destroy) }
    it { should have_many(:important_dates).dependent(:destroy) }
    it { should have_many(:interactions).dependent(:destroy) }
    it { should have_many(:reminders).dependent(:destroy) }
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:ring) }
  end

  describe "scopes" do
    let!(:active_person)  { create(:person) }
    let!(:deleted_person) { create(:person, deleted_at: Time.current) }

    it "active excludes deleted records" do
      expect(Person.active).to include(active_person)
      expect(Person.active).not_to include(deleted_person)
    end

    it "deleted excludes active records" do
      expect(Person.deleted).to include(deleted_person)
      expect(Person.deleted).not_to include(active_person)
    end
  end

  describe "#soft_delete" do
    let(:person) { create(:person) }

    it "sets deleted_at" do
      expect { person.soft_delete }.to change { person.reload.deleted_at }.from(nil)
    end
  end

  describe "#effective_cadence" do
    let(:person) { create(:person, score_source: :manual, cadence_days: 30) }

    it "returns cadence_days when no override" do
      expect(person.effective_cadence).to eq(30)
    end

    it "returns override when set" do
      person.cadence_override_days = 7
      expect(person.effective_cadence).to eq(7)
    end
  end

  describe "#compute_soi_score" do
    let(:person) do
      create(:person,
        ring:                      :network,
        importance_score:          3,
        value_exchange_score:      3,
        objective_alignment_score: 3
      )
    end

    it "sets soi_score on save" do
      expect(person.soi_score).to eq(13) # 3+3+3+1(no interactions)+3
    end

    it "sets cadence_days from soi_score" do
      expect(person.cadence_days).to eq(30)
    end

    it "recomputes when a score dimension changes" do
      expect { person.update!(ring: :board_of_advisors) }
        .to change { person.reload.soi_score }.from(13).to(14)
    end

    it "does not recompute when score_source is manual" do
      person.update!(score_source: :manual, soi_score: 99)
      person.update!(ring: :community)
      expect(person.reload.soi_score).to eq(99)
    end
  end
end
