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
      params[:phone_call] = phone_call
      params[:account] = params[:phone_call].account
      params[:carrier] = params[:phone_call].carrier
      params
    end
  end
end
