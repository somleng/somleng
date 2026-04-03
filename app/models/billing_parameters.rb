class BillingParameters
  attr_reader :phone_call

  def initialize(phone_call)
    @phone_call = phone_call
  end

  def to_h
    {
      enabled: phone_call.account.billing_enabled?,
      category: phone_call.tariff_schedule_category.to_s,
      billing_mode: phone_call.account.billing_mode
    }
  end
end
