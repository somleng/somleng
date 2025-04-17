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
      url_helpers.api_twilio_account_phone_call_recording_url(
        object.account,
        object.phone_call,
        object,
        subdomain: AppSettings.fetch(:api_subdomain)
      )
    end
  end
end
