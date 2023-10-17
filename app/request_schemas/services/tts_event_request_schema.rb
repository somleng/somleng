module Services
  class TTSEventRequestSchema < ServicesRequestSchema
    params do
      required(:provider).value(:str?, included_in?: TTSEvent.provider.values)
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
