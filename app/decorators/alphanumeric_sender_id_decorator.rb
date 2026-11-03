class AlphanumericSenderIDDecorator < SimpleDelegator
  class << self
    delegate :model_name, :human_attribute_name, to: "AlphanumericSenderID"
  end

  def status_color
    case
    when pending_approval?
      :secondary
    when approved?
      :success
    when rejected?, revoked?
      :danger
    end
  end
end
