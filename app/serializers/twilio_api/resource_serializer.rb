module TwilioAPI
  class ResourceSerializer < TwilioAPISerializer
    def attributes
      super.merge(
        "api_version" => nil,
        "sid" => nil,
        "account_sid" => nil,
        "date_created" => nil,
        "date_updated" => nil
      )
    end

    def date_created
      format_time(__getobj__.created_at)
    end

    def date_updated
      format_time(__getobj__.updated_at)
    end

    private

    def format_time(value)
      return if value.blank?

      value.utc.rfc2822
    end
  end
end
