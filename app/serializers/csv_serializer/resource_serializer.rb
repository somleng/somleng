module CSVSerializer
  class ResourceSerializer < ApplicationSerializer
    def attributes
      {
        created_at: nil,
        updated_at: nil
      }
    end

    def as_csv
      serializable_hash.values
    end

    def headers
      attributes.keys
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
