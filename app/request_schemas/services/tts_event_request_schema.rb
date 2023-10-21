module Services
  class TTSEventRequestSchema < ServicesRequestSchema
    params do
      required(:tts_voice).value(:str?, included_in?: TTSVoices::Voice.all.map(&:identifier))
      required(:phone_call).value(:str?)
      required(:num_chars).value(:integer, gteq?: 0)
    end

    def output
      params = super
      phone_call = PhoneCall.find(params[:phone_call])
      tts_voice = TTSVoices::Voice.find(params[:tts_voice])
      params[:phone_call] = phone_call
      params[:account] = phone_call.account
      params[:carrier] = phone_call.carrier
      params[:tts_provider] = tts_voice.provider
      params[:tts_engine] = tts_voice.engine
      params
    end
  end
end
