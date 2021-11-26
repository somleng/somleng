class APIResponder < ActionController::Responder
  include Responders::HttpCacheResponder

  def display(resource, given_options = {})
    serializer_class = options.delete(:serializer_class) || resource.serializer_class
    decorator_class = options.delete(:decorator_class) || resource.decorator_class
    resource_to_display = decorator_class.present? ? decorator_class.new(resource) : resource

    super(serializer_class.new(resource_to_display), given_options)
  end

  def api_behavior(*args, &block)
    return display(resource, status: :ok) if put? || patch?

    super
  end
end
