class Usage::Record::Calls < Usage::Record::CallsBase
  DESCRIPTION = "Voice Minutes"
  CATEGORY = "calls"

  def self.category
    CATEGORY
  end

  def self.description
    DESCRIPTION
  end
end
