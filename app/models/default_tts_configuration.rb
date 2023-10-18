class DefaultTTSConfiguration < ApplicationRecord
  belongs_to :account

  def tts_voice
    @tts_voice ||= TTSVoices::Voice.find(voice_identifier)
  end
end
