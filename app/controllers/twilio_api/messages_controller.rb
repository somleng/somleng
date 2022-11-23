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
        message = scope.create!(permitted_params)
        OutboundMessageJob.perform_later(message)
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