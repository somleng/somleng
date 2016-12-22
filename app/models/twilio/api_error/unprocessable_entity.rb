class Twilio::ApiError::UnprocessableEntity < Twilio::ApiError::Base
  DEFAULT_STATUS = 422

  def self.default_status
    DEFAULT_STATUS
  end
end
