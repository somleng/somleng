class AuthTokenDecorator < SimpleDelegator
  class << self
    delegate :model_name, :human_attribute_name, to: "Doorkeeper::AccessToken"
  end

  def status
    active? ? :active : :revoked
  end

  def human_status
    status.to_s.humanize
  end

  def status_color
    if active?
      :success
    else
      :danger
    end
  end

  def type
    primary? ? :primary : :secondary
  end

  def human_type
    type.to_s.humanize
  end

  def type_color
    if primary?
      :primary
    else
      :secondary
    end
  end
end
