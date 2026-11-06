class ProspectingController < ApplicationController
  def show
    @prospects = Contact.prospects
    @linkedin_contact = Contact.new(source: "linkedin", soi_ring: "strangers")
    @waas_contact = Contact.new(source: "work_at_a_startup", soi_ring: "strangers")
  end
end
