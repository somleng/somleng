class TTSEvent < ApplicationRecord
  extend Enumerize

  attribute :tts_voice, TTSVoiceType.new

  belongs_to :carrier
  belongs_to :account
  belongs_to :phone_call
end
