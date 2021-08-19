module Services
  class ResourceSerializer < TwilioAPISerializer
    def attributes
      super.merge(
        "created_at" => nil,
        "updated_at" => nil,
        "api_version" => nil
      )
    end

    def created_at
      format_time(super)
    end

    def updated_at
      format_time(super)
    end

    private

    def format_time(value)
      return if value.blank?

      value.utc.iso8601
    end
  end
end
