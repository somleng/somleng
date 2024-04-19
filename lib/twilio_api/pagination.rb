module TwilioAPI
  class Pagination
    DEFAULT_LIMIT_PER_PAGE = 50

    Info = Struct.new(
      :uri, :page_number, :page_size, :first_page_uri, :next_page_uri, :previous_page_uri,
      keyword_init: true
    )

    attr_reader :paginated_collection, :resources, :requested_uri, :params

    def initialize(resources, requested_uri)
      @resources = resources
      @requested_uri = URI.parse(requested_uri)
      @params = parse_params
      @paginated_collection = paginate_resources
    end

    def info
      @info ||= Info.new(
        uri: requested_uri,
        page_number:,
        page_size:,
        first_page_uri: pagination_link(PageToken: nil, Page: 0),
        next_page_uri: next_cursor && pagination_link(
          PageToken: "PA#{next_cursor}",
          Page: page_number + 1
        ),
        previous_page_uri: prev_cursor && pagination_link(
          PageToken: "PB#{prev_cursor}",
          Page: [
            page_number - 1, 0
          ].max
        )
      )
    end

    private

    def pagination_link(page_params)
      link = requested_uri.dup
      link.query = params.merge(page_params).compact.to_query
      link
    end

    def next_cursor
      @next_cursor ||= paginated_collection.next_cursor_params.fetch(:after)
    end

    def prev_cursor
      @prev_cursor ||= paginated_collection.prev_cursor_params.fetch(:before)
    end

    def paginate_resources
      CursorPaginator.paginate(
        apply_limit(resources),
        page_options: cursor_page_options,
        paginator_options: {
          order_key: :sequence_number
        }
      )
    end

    def cursor_page_options
      options = { size: page_size }
      options[:after] = page_cursor  if page_token&.start_with?("PA")
      options[:before] = page_cursor if page_token&.start_with?("PB")
      options
    end

    def page_size
      params.fetch(:PageSize, DEFAULT_LIMIT_PER_PAGE).to_i
    end

    def page_number
      params.fetch(:Page, 0).to_i
    end

    def page_cursor
      return if page_token.blank?

      page_token.sub(/\AP[AB]/, "")
    end

    def page_token
      params[:PageToken]
    end

    def apply_limit(resources)
      return resources if params[:limit].blank?

      resources.limit(params[:limit])
    end

    def parse_params
      Rack::Utils.parse_nested_query(requested_uri.query).with_indifferent_access
    end
  end
end
