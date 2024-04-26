class IncomingPhoneNumber < ApplicationRecord
  extend Enumerize

  belongs_to :carrier
  belongs_to :phone_number_plan
  belongs_to :account
  belongs_to :phone_number, optional: true
  belongs_to :messaging_service, optional: true

  enumerize :voice_method, in: %w[POST GET], default: "POST"
  enumerize :sms_method, in: %w[POST GET], default: "POST"
  enumerize :status_callback_method, in: %w[POST GET], default: "POST"
  enumerize :status, in: %w[active inactive], default: :active, scope: :shallow, predicates: true
  enumerize :account_type, in: Account.type.values, scope: :shallow

  attribute :number, PhoneNumberType.new
  attribute :phone_number_formatter, default: -> { PhoneNumberFormatter.new }

  before_validation :set_defaults, on: :create

  delegate :country, :type, to: :phone_number, allow_nil: true

  def self.configured
    where.not(voice_url: nil).or(where.not(sms_url: nil)).or(where.not(messaging_service_id: nil))
  end

  def self.unconfigured
    where(voice_url: nil, sms_url: nil, messaging_service_id: nil)
  end

  def configured?
    voice_url.present? || sms_url.present? || messaging_service_id.present?
  end

  def release!
    transaction do
      update!(status: :inactive)
      phone_number_plan.cancel!
    end
  end

  private

  def set_defaults
    return if account.blank? || phone_number.blank?

    self.account_type ||= account.type
    self.carrier ||= account.carrier
    self.number ||= phone_number.number
    self.friendly_name ||= phone_number_formatter.format(number, format: :national)
    self.phone_number_plan ||= build_phone_number_plan(
      phone_number:,
      account:,
      carrier: account.carrier,
      number: phone_number.number
    )
  end
end
