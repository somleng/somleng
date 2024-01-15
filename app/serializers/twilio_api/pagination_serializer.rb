module TwilioAPI
  class PaginationSerializer
    attr_reader :pagination_info

    def initialize(pagination_info)
      @pagination_info = pagination_info
    end

    def serializable_hash
      {
        uri: pagination_info.uri.request_uri,
        page: pagination_info.page_number,
        page_size: pagination_info.page_size,
        first_page_uri: pagination_info.first_page_uri&.request_uri,
        previous_page_uri: pagination_info.previous_page_uri&.request_uri,
        next_page_uri: pagination_info.next_page_uri&.request_uri
      }
    end
  end
end
