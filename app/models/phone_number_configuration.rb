class PhoneNumberConfiguration < ApplicationRecord
  extend Enumerize

  belongs_to :phone_number
  belongs_to :messaging_service, optional: true

  enumerize :voice_method, in: %w[POST GET]
  enumerize :sms_method, in: %w[POST GET]
  enumerize :status_callback_method, in: %w[POST GET]

  delegate :account, to: :phone_number

  def self.configured
    where.not(voice_url: nil).or(where.not(sms_url: nil)).or(where.not(messaging_service_id: nil))
  end

  def self.unconfigured
    where(voice_url: nil, sms_url: nil, messaging_service_id: nil)
  end

  def configured?
    voice_url.present? || sms_url.present? || messaging_service_id.present?
  end
end
