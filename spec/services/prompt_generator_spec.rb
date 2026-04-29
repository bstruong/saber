require "rails_helper"

RSpec.describe PromptGenerator do
  let(:today) { Date.new(2026, 7, 15) }
  let(:cultural_dates) do
    { "lunar_new_year" => { "2026" => "2026-07-20" } }
  end
  let(:person) { create(:person, name: "Sam Lee") }

  before { allow(Date).to receive(:today).and_return(today) }

  def generate(p = person)
    described_class.new(p, cultural_dates: cultural_dates).generate
  end

  describe "#generate" do
    it "uses an important date in window" do
      create(:important_date, person: person, name: "Birthday", month: 7, day: 20)
      expect(generate).to include("Sam's Birthday is in 5 days")
    end

    it "uses today phrasing when the date is today" do
      create(:important_date, person: person, name: "Birthday", month: 7, day: 15)
      expect(generate).to include("Today is Sam's Birthday")
    end

    it "ignores important dates outside the 14-day window" do
      create(:important_date, person: person, name: "Birthday", month: 9, day: 1)
      person.update!(notes: "context")
      expect(generate).to include("You have context")
    end

    it "uses a cultural prompt when a tagged event is in window" do
      person.update!(cultural_tags: [ "lunar_new_year" ])
      expect(generate).to include("Lunar New Year")
    end

    it "ignores cultural tags outside the window" do
      person.update!(cultural_tags: [ "lunar_new_year" ], notes: "context")
      allow(Date).to receive(:today).and_return(Date.new(2026, 1, 1))
      expect(generate).not_to include("Lunar New Year")
    end

    it "uses a relationship-holiday prompt when a tagged holiday is in window" do
      person.update!(relationship_tags: [ "parent" ])
      allow(Date).to receive(:today).and_return(Date.new(2027, 5, 5))
      expect(generate).to include("Mother's Day")
    end

    it "uses a needs prompt when needs are present" do
      person.update!(needs: "is looking for a new job.")
      expect(generate).to include("looking for a new job")
    end

    it "uses a notes prompt when only notes are present" do
      person.update!(notes: "Met at a conference")
      expect(generate).to include("You have context on Sam")
    end

    it "falls back to a generic activity prompt when no signals exist" do
      expect(generate).to include("haven't connected with Sam")
    end
  end

  describe "priority order" do
    it "prefers important dates over cultural tags" do
      create(:important_date, person: person, name: "Anniversary", month: 7, day: 20)
      person.update!(cultural_tags: [ "lunar_new_year" ])
      expect(generate).to include("Anniversary")
      expect(generate).not_to include("Lunar")
    end

    it "prefers cultural tags over relationship holidays" do
      person.update!(cultural_tags: [ "lunar_new_year" ], relationship_tags: [ "parent" ])
      expect(generate).to include("Lunar New Year")
    end

    it "prefers relationship holidays over needs" do
      person.update!(relationship_tags: [ "parent" ], needs: "needs help moving.")
      allow(Date).to receive(:today).and_return(Date.new(2027, 5, 5))
      expect(generate).to include("Mother's Day")
      expect(generate).not_to include("needs help")
    end

    it "prefers needs over notes" do
      person.update!(needs: "needs help moving.", notes: "Old friend")
      expect(generate).to include("needs help moving")
      expect(generate).not_to include("You have context")
    end
  end
end
