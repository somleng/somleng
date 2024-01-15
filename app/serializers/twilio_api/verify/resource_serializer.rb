module TwilioAPI
  module Verify
    class ResourceSerializer < TwilioAPISerializer
      def attributes
        super.merge(
          "sid" => nil,
          "account_sid" => nil,
          "date_created" => nil,
          "date_updated" => nil
        )
      end

      def sid
        object.id
      end

      def account_sid
        object.account_id
      end

      def date_created
        format_time(object.created_at)
      end

      def date_updated
        format_time(object.updated_at)
      end

      private

      def pagination_serializer
        PaginationSerializer.new(serializer_options.fetch(:pagination_info), key: collection_name)
      end

      def format_time(value)
        value.utc.iso8601
      end
    end
  end
end
