class TTSEventDecorator < SimpleDelegator
  def sid
    id
  end

  def account_sid
    account_id
  end

  def phone_call_sid
    phone_call_id
  end

  def characters
    num_chars
  end

  def voice
    tts_voice.to_s
  end
end
