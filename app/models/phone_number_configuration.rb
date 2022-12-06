class PhoneNumberConfiguration < ApplicationRecord
  extend Enumerize

  belongs_to :phone_number
  belongs_to :messaging_service, optional: true

  enumerize :voice_method, in: %w[POST GET]
  enumerize :sms_method, in: %w[POST GET]
  enumerize :status_callback_method, in: %w[POST GET]

  delegate :account, to: :phone_number
end
