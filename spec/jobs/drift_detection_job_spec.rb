require "rails_helper"

RSpec.describe DriftDetectionJob do
  describe "#perform" do
    # Outgoing command — mock the side effect
    it "delegates to DriftDetector" do
      expect(DriftDetector).to receive(:call)
      described_class.new.perform
    end
  end
end
