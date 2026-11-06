class InteractionLogger
  def self.call(contact:, attrs:)
    new(contact:, attrs:).call
  end

  def initialize(contact:, attrs:)
    @contact = contact
    @attrs = attrs
  end

  def call
    interaction = nil

    ActiveRecord::Base.transaction do
      interaction = @contact.interactions.create!(@attrs)
      @contact.update!(last_contacted_at: Time.current)
      ScorecardCalculator.new(@contact).apply!
    end

    interaction
  end
end
