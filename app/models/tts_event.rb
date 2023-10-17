class TTSEvent < ApplicationRecord
  extend Enumerize

  enumerize :provider, in: %i[basic polly]

  belongs_to :carrier
  belongs_to :account
  belongs_to :phone_call
end
