module ApplicationHelper
  def human_enum(value)
    value.to_s.tr("_", " ").split.map(&:capitalize).join(" ")
  end

  def source_label(source)
    case source.to_s
    when "work_at_a_startup" then "Work at a Startup"
    when "sf_ruby_meetup" then "SF Ruby Meetup"
    when "sf_incubator" then "SF Incubator"
    when "indie_hackers" then "Indie Hackers"
    when "direct_referral" then "Direct referral"
    when "linkedin" then "LinkedIn"
    else human_enum(source)
    end
  end

  def ring_label(ring)
    case ring.to_s
    when "board_of_advisors" then "Board of advisors"
    else human_enum(ring)
    end
  end

  def nav_link_class(active)
    active ? "is-active" : nil
  end
end
