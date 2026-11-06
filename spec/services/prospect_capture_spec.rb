require "rails_helper"

RSpec.describe ProspectCapture do
  it "creates a LinkedIn prospect in the strangers ring" do
    contact = described_class.call(
      attrs: {
        name: "Elena Voss",
        company: "Parcelkit",
        profile_url: "https://www.linkedin.com/in/elena",
        source: "linkedin",
        hook: "Freight waitlist"
      }
    )

    expect(contact).to be_persisted
    expect(contact.source).to eq("linkedin")
    expect(contact.soi_ring).to eq("strangers")
    expect(contact.last_contacted_at).to be_nil
    expect(contact.notes).to eq("Freight waitlist")
    expect(contact).to be_prospect
  end

  it "rejects non-prospect sources" do
    expect {
      described_class.call(attrs: { name: "X", source: "direct_referral" })
    }.to raise_error(ProspectCapture::Error)
  end
end
