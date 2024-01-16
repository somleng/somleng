module TwilioAPI
  class Responder < ApplicationResponder
    def display(resource, given_options = {})
      serializer_class = options.delete(:serializer_class)
      serializer_options = options.delete(:serializer_options) || {}

      resource = if resource_is_collection?(resource)
                   pagination = Pagination.new(resource, request.url)
                   serializer_options[:pagination_info] = pagination.info
                   pagination.paginated_collection.map(&:decorated)
                 else
                   resource.decorated
                 end

      super(serializer_class.new(resource, serializer_options), given_options)
    end

    def api_behavior(*args, &)
      return display(resource, status: :ok) if put? || patch?

      super
    end

    private

    def resource_is_collection?(resource)
      resource.respond_to?(:size) && !resource.respond_to?(:each_pair)
    end
  end
end
