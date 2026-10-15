class CarrierAPIKeyDecorator < SimpleDelegator
  class << self
    delegate :model_name, :human_attribute_name, to: "CarrierAPIKey"
  end

  delegate :status, :human_status, :status_color, to: :access_token_decorator

  private

  def access_token_decorator
    @access_token_decorator ||= AccessTokenDecorator.new(self)
  end
end
