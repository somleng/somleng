class TTSEvent < ApplicationRecord
  extend Enumerize

  enumerize :provider, in: [:polly]

  belongs_to :carrier
  belongs_to :account
  belongs_to :phone_call
end
