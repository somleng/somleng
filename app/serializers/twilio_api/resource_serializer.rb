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
      format_time(object.created_at)
    end

    def date_updated
      format_time(object.updated_at)
    end
  end
end
