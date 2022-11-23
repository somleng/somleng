class PhoneNumberConfiguration < ApplicationRecord
  extend Enumerize

  belongs_to :phone_number

  enumerize :voice_method, in: %w[POST GET]
  enumerize :sms_method, in: %w[POST GET]
  enumerize :status_callback_method, in: %w[POST GET]

  delegate :account, to: :phone_number

  def configured?(context)
    raise ArgumentError, "invalid context #{context}" unless context.in?(%i[message voice])

    context == :message ? sms_url.present? : voice_url.present?
  end
end
