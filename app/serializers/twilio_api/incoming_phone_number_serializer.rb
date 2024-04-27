module TwilioAPI
  class IncomingPhoneNumberSerializer < ResourceSerializer
    def attributes
      super.merge(
        account_sid: nil,
        address_requirements: nil,
        address_sid: nil,
        beta: nil,
        capabilities: nil,
        emergency_status: nil,
        emergency_address_sid: nil,
        emergency_address_status: nil,
        friendly_name: nil,
        identity_sid: nil,
        origin: nil,
        phone_number: nil,
        sid: nil,
        sms_application_sid: nil,
        sms_fallback_method: nil,
        sms_fallback_url: nil,
        sms_method: nil,
        sms_url: nil,
        status_callback: nil,
        status_callback_method: nil,
        trunk_sid: nil,
        uri: nil,
        voice_application_sid: nil,
        voice_caller_id_lookup: nil,
        voice_fallback_method: nil,
        voice_fallback_url: nil,
        voice_method: nil,
        voice_url: nil,
        bundle_sid: nil,
        voice_receive_mode: nil,
        status: nil
      )
    end

    def account_sid
      object.account_id
    end

    def address_requirements
      "none"
    end

    def address_sid; end

    def capabilities
      {
        voice: true,
        sms: true,
        mms: false,
        fax: false
      }
    end

    def beta
      false
    end

    def emergency_status
      "Inactive"
    end

    def emergency_address_sid; end

    def emergency_address_status
      "unregistered"
    end

    def identity_sid; end

    def origin
      "hosted"
    end

    def phone_number
      object.number
    end

    def sms_application_sid; end

    def sms_fallback_method
      "POST"
    end

    def sms_fallback_url; end

    def status_callback
      object.status_callback_url
    end

    def status_callback_method
      object.status_callback_method
    end

    def trunk_sid; end

    def uri
      url_helpers.api_twilio_account_incoming_phone_number_path(object.account, object, format: :json)
    end

    def voice_application_sid; end
    def voice_caller_id_lookup
      false
    end

    def voice_fallback_method
      "POST"
    end

    def voice_fallback_url; end

    def bundle_sid; end

    def voice_receive_mode
      "voice"
    end

    def status
      "in-use"
    end
  end
end
