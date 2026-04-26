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

  describe ".with_upcoming_events" do
    let(:person) { create(:person) }

    it "includes persons with an important date in the next 30 days" do
      soon = Date.today + 5
      create(:important_date, person: person, month: soon.month, day: soon.day)
      expect(Person.with_upcoming_events).to include(person)
    end

    it "excludes persons with no important dates" do
      expect(Person.with_upcoming_events).not_to include(person)
    end

    it "excludes persons with important dates outside the 30-day window" do
      later = Date.today + 31
      create(:important_date, person: person, month: later.month, day: later.day)
      expect(Person.with_upcoming_events).not_to include(person)
    end

    it "returns distinct results when a person has multiple upcoming dates" do
      soon      = Date.today + 5
      also_soon = Date.today + 10
      create(:important_date, person: person, month: soon.month,      day: soon.day)
      create(:important_date, person: person, month: also_soon.month, day: also_soon.day)
      expect(Person.with_upcoming_events.where(id: person.id).count).to eq(1)
    end
  end

  describe ".needs_reconnection" do
    let(:person) { create(:person) }

    it "includes persons never contacted" do
      person.update_columns(last_contacted_at: nil, cadence_days: 30)
      expect(Person.needs_reconnection).to include(person)
    end

    it "includes persons overdue based on cadence" do
      person.update_columns(last_contacted_at: 100.days.ago, cadence_days: 30)
      expect(Person.needs_reconnection).to include(person)
    end

    it "excludes persons contacted within their cadence" do
      person.update_columns(last_contacted_at: 10.days.ago, cadence_days: 30)
      expect(Person.needs_reconnection).not_to include(person)
    end

    it "uses cadence_override_days when set" do
      person.update_columns(last_contacted_at: 10.days.ago, cadence_days: 30, cadence_override_days: 7)
      expect(Person.needs_reconnection).to include(person)
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
