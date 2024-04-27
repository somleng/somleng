module TwilioAPI
  class Responder < ApplicationResponder
    def display(resource, given_options = {})
      serializer_class = options.delete(:serializer_class)
      serializer_options = options.delete(:serializer_options) || {}
      serializable_resource = if resource_is_collection?(resource)
        prepare_collection(resource, serializer_options)
      else
        resource.decorated
      end

      super(serializer_class.new(serializable_resource, serializer_options), given_options)
    end

    def api_behavior(*args, &)
      return display(resource, status: :ok) if put? || patch?

      super
    end

    private

    def resource_is_collection?(resource)
      resource.respond_to?(:size) && !resource.respond_to?(:each_pair)
    end

    def prepare_collection(collection, options = {})
      if options.fetch(:paginate, true)
        pagination = Pagination.new(collection, request.url)
        options[:pagination_info] = pagination.info
        pagination.paginated_collection.map(&:decorated)
      else
        options[:pagination_info] = Pagination::Info.new(uri: URI.parse(request.url))
        collection.map(&:decorated)
      end
    end
  end
end
