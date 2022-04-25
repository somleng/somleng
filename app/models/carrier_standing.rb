class CarrierStanding
  MAX_RESTRICTED_INTERACTIONS_PER_MONTH = 100

  attr_reader :carrier

  def initialize(carrier)
    @carrier = carrier
  end

  def good_standing?
    return true unless carrier.restricted?

    remaining_interactions.positive?
  end

  def remaining_interactions
    [(MAX_RESTRICTED_INTERACTIONS_PER_MONTH - interactions_this_month.count), 0].max
  end

  def interactions_this_month
    carrier.interactions.where(created_at: Time.current.all_month)
  end
end
