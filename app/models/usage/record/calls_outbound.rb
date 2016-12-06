class Usage::Record::CallsOutbound < Usage::Record::CallsBase
  DESCRIPTION = "Outbound Voice Minutes"
  CATEGORY = "calls-outbound"

  def self.category
    CATEGORY
  end

  def self.description
    DESCRIPTION
  end

  private

  def phone_calls
    super.outbound
  end
end
