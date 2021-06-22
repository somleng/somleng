class PhoneNumber < ApplicationRecord
  extend Enumerize

  belongs_to :carrier
  belongs_to :account, optional: true
  has_many :phone_calls

  enumerize :voice_method, in: %w[POST GET]
  enumerize :status_callback_method, in: %w[POST GET]
end
