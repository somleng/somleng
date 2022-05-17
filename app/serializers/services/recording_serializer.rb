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
      custom_domain = CustomDomain.verified.find_by(carrier: object.phone_call.carrier, host_type: :api)
      host = custom_domain.present? ? custom_domain.host : Rails.configuration.app_settings.fetch(:api_url_host)

      url_helpers.twilio_api_account_phone_call_recording_url(
        object.account,
        object.phone_call,
        object,
        host:
      )
    end
  end
end
