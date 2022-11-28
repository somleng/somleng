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
        message = Message.create!(permitted_params)
        OutboundMessageJob.perform_later(message)
        message
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
        **serializer_options
      ) do |permitted_params|
        message.update!(permitted_params)
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

    def serializer_options
      { serializer_class: MessageSerializer }
    end
  end
end
