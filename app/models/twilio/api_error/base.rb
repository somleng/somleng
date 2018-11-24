class Twilio::ApiError::Base
  attr_accessor :code, :detail, :message, :more_info, :status

  delegate :default_code, :default_detail,
           :default_message, :default_more_info,
           :default_status, to: :class

  def initialize(options = {})
    self.code = options[:code] || default_code
    self.detail = options[:detail] || default_detail
    self.message = options[:message] || default_message
    self.more_info = options[:more_info] || default_more_info(code)
    self.status = options[:status] || default_status
  end

  def self.default_code; end

  def self.default_detail; end

  def self.default_message; end

  def self.default_status; end

  def self.default_more_info(code)
    "https://www.twilio.com/docs/errors/#{code}" if code.present?
  end

  def to_hash
    hash = {}
    hash["status"] = status if status.present?
    hash["message"] = message if message.present?
    hash["code"] = code if code.present?
    hash["detail"] = detail if detail.present?
    hash["more_info"] = more_info if more_info.present?
    hash
  end
end
