class UserDecorator < SimpleDelegator
  class << self
    delegate :model_name, :human_attribute_name, to: "User"
  end

  def otp_required_for_login
    !!object.otp_required_for_login
  end

  private

  def object
    __getobj__
  end
end
