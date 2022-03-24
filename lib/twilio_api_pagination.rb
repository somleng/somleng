class TwilioAPIPagination
  DEFAULT_LIMIT_PER_PAGE = 50
  MAX_LIMIT_PER_PAGE = 1000

  attr_reader :paginated_collection, :resources, :requested_uri, :params

  def initialize(resources, requested_uri)
    @resources = resources
    @requested_uri = URI.parse(requested_uri)
    @params = parse_params
    @paginated_collection = paginate_resources
  end

  def info
    @info ||= {
      uri: requested_uri,
      page: page_number,
      page_size: page_size,
      first_page_uri: pagination_link(PageToken: nil, Page: 0),
      next_page_uri: next_cursor && pagination_link(PageToken: "PA#{next_cursor}", Page: page_number + 1),
      previous_page_uri: prev_cursor && pagination_link(PageToken: "PB#{prev_cursor}", Page: (page_number.zero? ? 0 : page_number - 1))
    }
  end

  private

  def pagination_link(page_params)
    link = requested_uri.dup
    link.query = params.merge(page_params).compact.to_query
    link.to_s
  end

  def next_cursor
    @next_cursor ||= paginated_collection.next_cursor_params.fetch(:after)
  end

  def prev_cursor
    @prev_cursor ||= paginated_collection.prev_cursor_params.fetch(:before)
  end

  def paginate_resources
    CursorPaginator.paginate(
      resources,
      page_options: page_options,
      paginator_options: {
        order_key: :sequence_number
      }
    )
  end

  def page_options
    options = { size: page_size }
    options[:after] = page_cursor  if page_token&.start_with?("PA")
    options[:before] = page_cursor if page_token&.start_with?("PB")
    options
  end

  def page_size
    [params.fetch(:PageSize, DEFAULT_LIMIT_PER_PAGE).to_i, MAX_LIMIT_PER_PAGE].min
  end

  def page_number
    params.fetch(:Page, 0).to_i
  end

  def page_cursor
    return if page_token.blank?

    page_token.sub(/P[AB]/, "")
  end

  def page_token
    params[:PageToken]
  end

  def parse_params
    Rack::Utils.parse_nested_query(requested_uri.query).with_indifferent_access
  end
end
