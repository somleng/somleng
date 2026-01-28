module TwilioAPI
  class PhoneCallSerializer < ResourceSerializer
    def attributes
      super.merge(
        account_sid: nil,
        annotation: nil,
        answered_by: nil,
        caller_name: nil,
        direction: nil,
        duration: nil,
        end_time: nil,
        forwarded_from: nil,
        from: nil,
        from_formatted: nil,
        group_sid: nil,
        parent_call_sid: nil,
        phone_number_sid: nil,
        price: nil,
        price_unit: nil,
        start_time: nil,
        status: nil,
        subresource_uris: nil,
        to: nil,
        to_formatted: nil,
        uri: nil
      )
    end

    def account_sid
      account_id
    end

    def phone_number_sid
      incoming_phone_number_id
    end

    def annotation; end

    def answered_by; end

    def caller_name; end

    def end_time
      format_time(call_data_record.end_time)
    end

    def forwarded_from; end

    def group_sid; end

    def parent_call_sid
      parent_call_id
    end

    def start_time
      format_time(call_data_record.start_time)
    end

    def subresource_uris
      {}
    end

    def uri
      url_helpers.api_twilio_account_phone_call_path(account, object, format: :json)
    end

    def collection_name
      "calls"
    end

    def price
      object.price_formatted
    end
  end
end
