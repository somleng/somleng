class AudioStream < ApplicationRecord
  belongs_to :account
  belongs_to :phone_call
end
