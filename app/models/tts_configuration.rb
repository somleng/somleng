class TTSConfiguration < ApplicationRecord
  extend Enumerize

  belongs_to :account

  enumerize :voice_identifier, in: TTSVoices::Voice.all.map(&:identifier),
                               default: TTSVoices::Voice.default.identifier

  def tts_voice
    @tts_voice ||= TTSVoices::Voice.find(voice_identifier)
  end
end
