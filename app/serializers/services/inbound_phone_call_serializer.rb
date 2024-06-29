module Services
  class InboundPhoneCallSerializer < ResourceSerializer
    def attributes
      super.merge(
        "voice_url" => nil,
        "voice_method" => nil,
        "status_callback_url" => nil,
        "status_callback_method" => nil,
        "twiml" => nil,
        "to" => nil,
        "from" => nil,
        "sid" => nil,
        "account_sid" => nil,
        "account_auth_token" => nil,
        "direction" => nil,
        "api_version" => nil,
        "default_tts_voice" => nil
      )
    end

    def api_version
      TwilioAPI::ResourceSerializer::API_VERSION
    end

    def account_auth_token
      object.account.auth_token
    end

    def default_tts_voice
      object.default_tts_voice.identifier
    end
  end
end
