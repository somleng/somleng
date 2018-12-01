module API
  class PhoneCallSerializer < AbstractPhoneCallSerializer
    PRICE_UNIT = "USD".freeze

    CALL_STATUS_MAPPINGS = {
      "queued" => "queued",
      "initiated" => "queued",
      "ringing" => "ringing",
      "answered" => "in-progress",
      "busy" => "busy",
      "failed" => "failed",
      "not_answered" => "no-answer",
      "completed" => "completed",
      "canceled" => "canceled"
    }.freeze

    attributes :account_sid, :annotation, :answered_by, :api_version,
               :caller_name, :date_created, :date_updated, :direction, :duration,
               :end_time, :forwarded_from, :from, :from_formatted, :group_sid,
               :parent_call_sid, :phone_number_sid, :price, :price_unit,
               :sid, :start_time, :status,
               :subresource_uris, :to, :to_formatted, :uri

    def annotation; end

    def answered_by; end

    def caller_name; end

    def forwarded_from; end

    def group_sid; end

    def parent_call_sid; end

    def price; end

    def phone_number_sid
      serializable.incoming_phone_number&.id
    end

    def price_unit
      PRICE_UNIT
    end

    def duration
      cdr&.bill_sec
    end

    def end_time
      cdr&.end_time&.rfc2822
    end

    def start_time
      cdr&.answer_time&.rfc2822
    end

    def from_formatted
      format_number(serializable.from)
    end

    def status
      CALL_STATUS_MAPPINGS.fetch(serializable.status)
    end

    def to_formatted
      format_number(serializable.to)
    end

    def uri
      url_helpers.api_twilio_account_call_path(serializable.account, serializable.id)
    end

    def subresource_uris
      {
        "recordings" => url_helpers.api_twilio_account_call_recordings_path(
          serializable.account_id, serializable.id
        )
      }
    end

    private

    def format_number(number)
      normalized_number = safe_phony_normalize(number)
      return nil if normalized_number.blank?

      Phony.format(normalized_number, format: :international)
    end

    def safe_phony_normalize(number)
      Phony.normalize(number)
    rescue StandardError
      nil
    end
  end
end
