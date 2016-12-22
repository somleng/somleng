class Twilio::ApiError::NotFound < Twilio::ApiError::Base
  attr_accessor :request_url

  DEFAULT_CODE = 20404
  DEFAULT_STATUS = 404

  def initialize(options = {})
    self.request_url = options[:request_url]
    super
  end

  def self.default_code
    DEFAULT_CODE
  end

  def self.default_status
    DEFAULT_STATUS
  end

  def message
    "The requested resource #{request_url} was not found" if request_url.present?
  end
end
