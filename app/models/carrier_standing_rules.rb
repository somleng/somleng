class CarrierStandingRules
  attr_reader :error_message

  def valid?(carrier:)
    return true if CarrierStanding.new(carrier).good_standing?

    @error_message = "Carrier is not in good standing"
    false
  end
end
