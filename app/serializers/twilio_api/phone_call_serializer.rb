module TwilioAPI
  class PhoneCallSerializer < ResourceSerializer
    def attributes
      super.merge(
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

    def annotation; end

    def answered_by; end

    def caller_name; end

    def end_time
      format_time(call_data_record.end_time)
    end

    def forwarded_from; end

    def group_sid; end

    def parent_call_sid; end

    def start_time
      format_time(call_data_record.start_time)
    end

    def subresource_uris
      {}
    end

    def uri
      url_helpers.twilio_api_account_phone_call_url(account, __getobj__, format: :json, subdomain: "api")
    end
  end
end
