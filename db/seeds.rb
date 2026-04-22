User.find_or_create_by!(email: "brian@example.com") do |u|
  u.password = "password123"
end

alex = Person.find_or_create_by!(name: "Alex Chen") do |p|
  p.ring              = :network
  p.notes             = "Met at SF Ruby meetup. Works on distributed systems at Stripe. Thoughtful, low-ego, always has interesting takes."
  p.needs             = "Looking for angel investors for his next venture. Can offer deep infra advice and warm intros to eng leadership."
  p.soi_score         = 14
  p.score_source      = :computed
  p.cadence_days      = 30
  p.last_contacted_at = 6.weeks.ago
  p.relationship_tags = [ "colleague", "mentor" ]
end

alex.contact_methods.find_or_create_by!(method_type: :linkedin, value: "linkedin.com/in/alexchen")
alex.contact_methods.find_or_create_by!(method_type: :email,    value: "alex@example.com")

alex.important_dates.find_or_create_by!(name: "Birthday", month: 6, day: 15)
