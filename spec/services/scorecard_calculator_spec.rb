require "rails_helper"

RSpec.describe ScorecardCalculator do
  let(:contact) do
    build(
      :contact,
      goal_importance: 4,
      ring_level: 4,
      value_exchange: 4,
      past_interaction_freq: 4,
      objective_alignment: 4,
      last_contacted_at: Time.current
    )
  end

  subject(:calculator) { described_class.new(contact) }

  it "sums scorecard dimensions" do
    expect(calculator.score).to eq(20)
  end

  it "maps high scores to weekly cadence" do
    expect(calculator.follow_up_frequency).to eq("weekly")
  end

  it "maps mid scores to monthly cadence" do
    contact.assign_attributes(
      goal_importance: 3,
      ring_level: 3,
      value_exchange: 3,
      past_interaction_freq: 2,
      objective_alignment: 3
    )
    expect(calculator.score).to eq(14)
    expect(calculator.follow_up_frequency).to eq("monthly")
  end

  it "applies score, frequency, and next due onto the record" do
    calculator.apply_to_record
    expect(contact.total_score).to eq(20)
    expect(contact.follow_up_frequency).to eq("weekly")
    expect(contact.next_follow_up_due).to be_within(2.seconds).of(7.days.from_now)
  end
end
