class CarrierStanding
  MAX_TRIAL_INTERACTIONS_PER_MONTH = 100

  attr_reader :carrier

  def initialize(carrier)
    @carrier = carrier
  end

  def good_standing?
    return true unless carrier.restricted?

    remaining_interactions.positive?
  end

  def remaining_interactions
    [ interactions_limit - interactions_this_month.count, 0 ].max
  end

  def interactions_this_month
    carrier.interactions.where(created_at: Time.current.all_month)
  end

  def interactions_limit
    [
      carrier.trial_interactions_credit_vouchers.where(valid_at: Time.current.all_month).sum(:number_of_interactions),
      MAX_TRIAL_INTERACTIONS_PER_MONTH
    ].max
  end
end
