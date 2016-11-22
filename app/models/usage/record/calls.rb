class Usage::Record::Calls < Usage::Record::Base
  DESCRIPTION = "Voice Minutes"
  CATEGORY = "calls"
  COUNT_UNIT = "calls"
  USAGE_UNIT = "minutes"
  PRICE_UNIT = "usd"

  def self.category
    CATEGORY
  end

  def self.description
    DESCRIPTION
  end

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
    phone_calls.sum(:price)
  end

  private

  def phone_calls
    account.phone_calls.billable.between_dates(start_date, end_date)
  end
end
