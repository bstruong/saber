class DashboardController < ApplicationController
  def show
    @prospects = Contact.prospects.limit(5)
    @prospect_count = Contact.prospects.count
    @follow_ups = Contact.follow_up_due.limit(10)
    @follow_up_count = Contact.follow_up_due.count
    @sunday_checklist = SundayChecklist.for_current_week
  end
end
