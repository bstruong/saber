class ProspectCapture
  class Error < StandardError; end

  ALLOWED_SOURCES = Contact::PROSPECT_SOURCES

  def self.call(attrs:)
    new(attrs:).call
  end

  def initialize(attrs:)
    @attrs = attrs.to_h.symbolize_keys
  end

  def call
    source = @attrs[:source].to_s
    raise Error, "Source must be linkedin or work_at_a_startup" unless ALLOWED_SOURCES.include?(source)

    hook = @attrs[:hook].presence || @attrs[:hook_note].presence || @attrs[:notes].presence

    Contact.create!(
      name:                  @attrs.fetch(:name),
      company:               @attrs[:company],
      profile_url:           @attrs[:profile_url],
      email:                 @attrs[:email],
      phone:                 @attrs[:phone],
      source:                source,
      soi_ring:              "strangers",
      goal_importance:       1,
      ring_level:            1,
      value_exchange:        1,
      past_interaction_freq: 1,
      objective_alignment:   1,
      notes:                 hook,
      last_contacted_at:     nil
    )
  end
end
