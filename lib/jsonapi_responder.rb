require_relative "application_responder"

class JSONAPIResponder < ApplicationResponder
  def display(resource, given_options = {})
    serializer_class = options.delete(:serializer_class) || resource.serializer_class
    serializer_options = options.delete(:serializer_options) || {}
    if request.query_parameters.key?(:include)
      serializer_options[:include] = request.query_parameters.fetch(:include).split(",")
    end

    if resource_is_collection?(resource)
      pagination = JSONAPIPagination.new(resource, request.original_url)
      links = serializer_options.fetch(:links, {})
      serializer_options[:links] = pagination.links.merge(links)
      resource = pagination.paginated_collection
    end

    given_options[:status] = :payment_required if resource.is_a?(BusinessRuleAPIError)
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
