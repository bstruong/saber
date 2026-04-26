require "rails_helper"

RSpec.describe SoiScoreCalculator do
  def baseline_person(**overrides)
    create(:person,
      ring:                      :stranger,
      score_source:              :manual,
      importance_score:          1,
      value_exchange_score:      1,
      objective_alignment_score: 1,
      **overrides
    )
  end

  describe "#score" do
    it "sums all 5 dimensions" do
      person = baseline_person(ring: :network, importance_score: 3, value_exchange_score: 3, objective_alignment_score: 3)
      # importance=3, ring=3, value_exchange=3, interaction_frequency=1, objective=3
      expect(described_class.new(person).score).to eq(13)
    end

    it "defaults nil dimension scores to 1" do
      person = create(:person, score_source: :manual, importance_score: nil, value_exchange_score: nil, objective_alignment_score: nil)
      expect(described_class.new(person).score).to be >= 5
    end

    it "applies correct ring scores" do
      {
        board_of_advisors: 4,
        network:           3,
        community:         2,
        audience:          1,
        stranger:          1
      }.each do |ring, ring_score|
        person = baseline_person(ring: ring)
        expect(described_class.new(person).score).to eq(4 + ring_score), "#{ring} should contribute #{ring_score}"
      end
    end

    context "interaction frequency" do
      let(:person) { baseline_person } # base without dim4 = 4, so score = 4 + dim4

      it "scores 1 for no recent interactions" do
        expect(described_class.new(person).score).to eq(5)
      end

      it "scores 2 for 1-2 interactions in last 6 months" do
        create(:interaction, person: person, occurred_at: 1.month.ago)
        expect(described_class.new(person).score).to eq(6)
      end

      it "scores 3 for 3-5 interactions in last 6 months" do
        create_list(:interaction, 3, person: person, occurred_at: 1.month.ago)
        expect(described_class.new(person).score).to eq(7)
      end

      it "scores 4 for 6+ interactions in last 6 months" do
        create_list(:interaction, 6, person: person, occurred_at: 1.month.ago)
        expect(described_class.new(person).score).to eq(8)
      end

      it "ignores interactions older than 6 months" do
        create(:interaction, person: person, occurred_at: 7.months.ago)
        expect(described_class.new(person).score).to eq(5)
      end
    end
  end

  describe "#cadence_days" do
    it "returns 14 days for score 17-20" do
      person = baseline_person(ring: :board_of_advisors, importance_score: 4, value_exchange_score: 4, objective_alignment_score: 4)
      # 4+4+4+1+4 = 17
      expect(described_class.new(person).cadence_days).to eq(14)
    end

    it "returns 30 days for score 13-16" do
      person = baseline_person(ring: :network, importance_score: 3, value_exchange_score: 3, objective_alignment_score: 3)
      # 3+3+3+1+3 = 13
      expect(described_class.new(person).cadence_days).to eq(30)
    end

    it "returns 90 days for score 9-12" do
      person = baseline_person(ring: :community, importance_score: 2, value_exchange_score: 2, objective_alignment_score: 2)
      # 2+2+2+1+2 = 9
      expect(described_class.new(person).cadence_days).to eq(90)
    end

    it "returns 180 days for score 5-8" do
      person = baseline_person
      # 1+1+1+1+1 = 5
      expect(described_class.new(person).cadence_days).to eq(180)
    end
  end
end
