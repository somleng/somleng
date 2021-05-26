class APIResponder < ActionController::Responder
  include Responders::HttpCacheResponder

  def display(resource, given_options = {})
    serializer_class = options.delete(:serializer_class) || resolve_serializer_class(resource)

    super(serializer_class.new(resource), given_options)
  end

  def api_behavior(*args, &block)
    return display(resource, status: :ok) if put? || patch?

    super
  end

  private

  def resolve_serializer_class(resource)
    return resource.serializer_class if resource.respond_to?(:serializer_class)

    "#{resource.class}Serializer".constantize
  end
end
