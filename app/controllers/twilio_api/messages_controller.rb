module TwilioAPI
  class MessagesController < TwilioAPIController
    def index
      respond_with(scope, serializer_options)
    end

    def create
      validate_request_schema(
        with: MessageRequestSchema,
        schema_options: { account: current_account },
        **serializer_options
      ) do |permitted_params|
        CreateMessage.call(permitted_params.merge(direction: :outbound_api))
      end
    end

    def show
      message = scope.find(params[:id])
      respond_with_resource(message, serializer_options)
    end

    def update
      message = scope.find(params[:id])

      validate_request_schema(
        with: UpdateMessageRequestSchema,
        schema_options: { account: current_account, message: },
        status: :ok,
        **serializer_options
      ) do |permitted_params|
        UpdateMessage.call(message, permitted_params)
      end
    end

    def destroy
      message = scope.find(params[:id])

      validate_request_schema(
        with: DeleteMessageRequestSchema,
        schema_options: { account: current_account, message: },
        **serializer_options
      ) do
        message.destroy!
        message
      end
    end

    private

    def scope
      current_account.messages
    end

    def respond_with_resource(resource, options)
      super(resource.account, resource, options)
    end

    def serializer_options
      { serializer_class: MessageSerializer }
    end
  end
end
