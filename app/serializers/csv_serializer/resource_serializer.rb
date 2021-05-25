module CSVSerializer
  class ResourceSerializer < ApplicationSerializer
    def serializable_hash(_options = nil)
      super.merge(
        sid: object.id,
        created_at: format_time(object.created_at),
        updated_at: format_time(object.updated_at)
      )
    end

    def as_csv
      serializable_hash.values
    end

    private

    def format_time(value)
      return if value.blank?

      value.utc.iso8601
    end
  end
end
