class APIResponder < ActionController::Responder
  include Responders::HttpCacheResponder

  def display(resource, given_options = {})
    serializer_class = options.delete(:serializer_class)
    serializer_options = options.delete(:serializer_options)
    super(serializer_class.new(resource, serializer_options), given_options)
  end

  def api_behavior(*args, &block)
    return display(resource, status: :ok) if put? || patch?

    super
  end
end
