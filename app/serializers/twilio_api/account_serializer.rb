module TwilioAPI
  class AccountSerializer < ResourceSerializer
    def attributes
      super.merge(
        auth_token: nil,
        friendly_name: nil,
        owner_account_sid: nil,
        status: nil,
        type: nil,
        uri: nil,
        subresource_uris: nil
      )
    end

    def friendly_name
      name
    end

    def type
      "Full"
    end

    def status
      object.enabled? ? "active" : "suspended"
    end

    def owner_account_sid
      owner&.id
    end

    def subresource_uris
      {
        calls: url_helpers.api_twilio_account_phone_calls_path(object, format: :json),
        messages: url_helpers.api_twilio_account_messages_path(object, format: :json),
        recordings: url_helpers.api_twilio_account_recordings_path(object, format: :json)
      }
    end

    def uri
      url_helpers.api_twilio_account_path(object, format: :json)
    end
  end
end
