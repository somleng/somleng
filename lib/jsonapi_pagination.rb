class JSONAPIPagination
  attr_reader :paginated_collection, :resources, :original_uri, :params, :pagination_options

  def initialize(resources, original_url, **options)
    @resources = resources
    @original_uri = URI.parse(original_url)
    @params = parse_params
    @pagination_options = options.fetch(:pagination_options, {})
    @paginated_collection = paginate_resources
  end

  def links
    @links ||= build_pagination_links
  end

  private

  def build_pagination_links
    {
      prev: pagination_link(paginated_collection.prev_cursor_params.merge(after: nil)),
      next: pagination_link(paginated_collection.next_cursor_params.merge(before: nil))
    }
  end

  def pagination_link(link_params)
    return if link_params.compact.blank?

    new_page_params = page_params.merge(link_params).compact
    link = original_uri.dup
    link.query = params.merge(page: new_page_params).to_query
    link.to_s
  end

  def parse_params
    Rack::Utils.parse_nested_query(original_uri.query).with_indifferent_access
  end

  def paginate_resources
    CursorPaginator.paginate(
      resources,
      page_options: page_params.slice(:before, :after, :size),
      paginator_options: {
        order_key: :sequence_number, **pagination_options
      }
    )
  end

  def page_params
    Hash.try_convert(params[:page]) || {}
  end
end
