module TwilioAPI
  class MessageSerializer < ResourceSerializer
    def attributes
      super.merge(
        account_sid: nil,
        body: nil,
        date_sent: nil,
        direction: nil,
        error_code: nil,
        error_message: nil,
        from: nil,
        messaging_service_sid: nil,
        num_media: nil,
        num_segments: nil,
        price: nil,
        price_unit: nil,
        status: nil,
        subresource_uris: nil,
        tags: nil,
        to: nil,
        uri: nil
      )
    end

    def account_sid
      account_id
    end

    def messaging_service_sid
      messaging_service_id
    end

    def num_media
      "0"
    end

    def num_segments
      object.segments.to_s
    end

    def date_sent
      format_time(object.sent_at)
    end

    def subresource_uris
      {}
    end

    def tags
      {}
    end

    def uri
      url_helpers.api_twilio_account_message_path(account, object, format: :json)
    end

    def collection_name
      "messages"
    end

    def price
      object.price_formatted
    end
  end
end
