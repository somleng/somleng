class PhoneNumberConfiguration < ApplicationRecord
  extend Enumerize

  belongs_to :phone_number

  enumerize :voice_method, in: %w[POST GET]
  enumerize :status_callback_method, in: %w[POST GET]
end
