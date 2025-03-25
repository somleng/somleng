module TwilioAPI
  class RecordingSerializer < ResourceSerializer
    def attributes
      super.merge(
        account_sid: nil,
        call_sid: nil,
        conference_sid: nil,
        channels: nil,
        start_time: nil,
        duration: nil,
        price: nil,
        price_unit: nil,
        source: nil,
        status: nil,
        error_code: nil,
        encryption_details: nil,
        track: nil,
        uri: nil,
        media_url: nil
      )
    end

    def call_sid
      object.phone_call_id
    end

    def account_sid
      account_id
    end

    def conference_sid; end

    def start_time
      created_at
    end

    def price; end

    def price_unit; end

    def error_code; end

    def encryption_details; end

    def uri
      url_helpers.api_twilio_account_phone_call_recording_path(
        object.account,
        object.phone_call,
        object,
        format: :json
      )
    end

    def media_url
      url_helpers.api_twilio_account_phone_call_recording_url(
        object.account,
        object.phone_call,
        object,
        subdomain: AppSettings.config_for(:api_subdomain)
      )
    end
  end
end
