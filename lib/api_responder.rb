class APIResponder < ActionController::Responder
  include Responders::HttpCacheResponder

  def display(resource, given_options = {})
    serializer_class = options.delete(:serializer_class) || resolve_serializer_class(resource)
    decorator_class = options.delete(:decorator_class) || resolve_decorator_class(resource)
    resource_to_display = decorator_class.present? ? decorator_class.new(resource) : resource

    super(serializer_class.new(resource_to_display), given_options)
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

  def resolve_decorator_class(resource)
    return resource.decorator_class if resource.respond_to?(:decorator_class)

    "#{resource.class}Decorator".safe_constantize
  end
end
