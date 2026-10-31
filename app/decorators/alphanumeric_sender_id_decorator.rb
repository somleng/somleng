class AlphanumericSenderIDDecorator < SimpleDelegator
  class << self
    delegate :model_name, :human_attribute_name, to: "AlphanumericSenderID"
  end

  def approval_status_color
    case
    when pending_approval?
      :secondary
    when approved?
      :success
    when rejected?
      :danger
    end
  end
end
