module Services
  class RecordingSerializer < ResourceSerializer
    def attributes
      super.merge(
        "sid" => nil,
        "duration" => nil,
        "url" => nil
      )
    end

    def url
      url_helpers.twilio_api_account_phone_call_recording_url(
        object.account,
        object.phone_call,
        object,
        host: Rails.configuration.app_settings.fetch(:api_url_host)
      )
    end
  end
end
