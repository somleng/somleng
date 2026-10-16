class AuthTokenDecorator < SimpleDelegator
  class << self
    delegate :model_name, :human_attribute_name, to: "AuthToken"
  end

  delegate :status, :human_status, :status_color, to: :access_token_decorator

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

  private

  def access_token_decorator
    @access_token_decorator ||= AccessTokenDecorator.new(self)
  end
end
