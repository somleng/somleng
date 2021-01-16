class IncomingPhoneNumber < ApplicationRecord
  extend Enumerize

  belongs_to :account
  has_many :phone_calls

  enumerize :voice_method, in: %w[POST GET]
  enumerize :status_callback_method, in: %w[POST GET]
end
