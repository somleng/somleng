module Services
  class ResourceSerializer < ApplicationSerializer
    def attributes
      super.merge(
        "created_at" => nil,
        "updated_at" => nil
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
