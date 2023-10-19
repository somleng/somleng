class TTSVoiceType < ActiveRecord::Type::String
  def cast(value)
    return if value.blank?

    value.is_a?(TTSVoices::Voice) ? value : TTSVoices::Voice.find(value)
  end

  def serialize(value)
    return if value.blank?

    value.identifier
  end
end
