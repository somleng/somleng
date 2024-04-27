module TwilioAPI
  class NoPaginationSerializer
    attr_reader :pagination_info

    def initialize(pagination_info)
      @pagination_info = pagination_info
    end

    def serializable_hash
      {
        uri: pagination_info.uri.request_uri
      }
    end
  end
end
