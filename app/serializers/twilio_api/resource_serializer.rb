module TwilioAPI
  class ResourceSerializer < TwilioAPISerializer
    API_VERSION = "2010-04-01".freeze

    def attributes
      super.merge(
        "api_version" => nil,
        "sid" => nil,
        "date_created" => nil,
        "date_updated" => nil
      )
    end

    def api_version
      API_VERSION
    end

    def sid
      object.id
    end

    def date_created
      format_time(object.created_at)
    end

    def date_updated
      format_time(object.updated_at)
    end

    private

    def format_time(value)
      return if value.blank?

      value.utc.rfc2822
    end

    def format_price(value)
      return if value.blank?

      "-%0.5f" % value.to_f
    end
  end
end
