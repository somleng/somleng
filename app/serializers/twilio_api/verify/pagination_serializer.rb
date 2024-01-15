module TwilioAPI
  module Verify
    class PaginationSerializer
      attr_reader :pagination_info, :key

      def initialize(pagination_info, key:)
        @pagination_info = pagination_info
        @key = key
      end

      def serializable_hash
        {
          meta: {
            url: pagination_info.uri,
            page: pagination_info.page_number,
            page_size: pagination_info.page_size,
            first_page_url: pagination_info.first_page_uri,
            previous_page_url: pagination_info.previous_page_uri,
            next_page_url: pagination_info.next_page_uri,
            key:
          }
        }
      end
    end
  end
end
