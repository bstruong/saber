# Single Responsibility - only schedules drift detection

class DriftDetectionJob < ApplicationJob
  queue_as :default

  def perform
    DriftDetector.call
  end
end
