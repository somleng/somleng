class Usage::Record::CallsInbound < Usage::Record::CallsBase
  DESCRIPTION = "Inbound Voice Minutes"
  CATEGORY = "calls-inbound"

  def self.category
    CATEGORY
  end

  def self.description
    DESCRIPTION
  end

  private

  def phone_calls
    super.inbound
  end
end
