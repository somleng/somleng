class TwilioAPIResponder < ApplicationResponder
  def display(resource, given_options = {})
    serializer_class = options.delete(:serializer_class)
    serializer_options = options.delete(:serializer_options) || {}

    resource = if resource_is_collection?(resource)
                 pagination = TwilioAPIPagination.new(resource, request.fullpath)
                 serializer_options[:pagination_info] = pagination.info
                 pagination.paginated_collection.map(&:decorated)
               else
                 resource.decorated
               end

    super(serializer_class.new(resource, serializer_options), given_options)
  end

  def api_behavior(*args, &block)
    return display(resource, status: :ok) if put? || patch?

    super
  end

  private

  def resource_is_collection?(resource)
    resource.respond_to?(:size) && !resource.respond_to?(:each_pair)
  end
end
