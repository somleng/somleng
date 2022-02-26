module Services
  class RecordingSerializer < ResourceSerializer
    def attributes
      super.merge(
        "sid" => nil,
        "account_sid" => nil,
        "status" => nil,
        "external_id" => nil,
        "duration" => nil,
        "url" => nil
      )
    end

    def url
      url_helpers.twilio_api_account_phone_call_recording_url(object.account, object.phone_call, object)
    end
  end
end
