class Usage::Record::CallsBase < Usage::Record::Base
  COUNT_UNIT = "calls"
  USAGE_UNIT = "minutes"
  PRICE_UNIT = "usd"

  def self.count_unit
    COUNT_UNIT
  end

  def self.usage_unit
    USAGE_UNIT
  end

  def self.price_unit
    PRICE_UNIT
  end

  def count
    phone_calls.count
  end

  def usage
    phone_calls.bill_minutes
  end

  def price
    phone_calls.total_price_in_usd.to_s
  end

  private

  def phone_calls
    account.phone_calls.billable.between_dates(start_date, end_date)
  end
end
