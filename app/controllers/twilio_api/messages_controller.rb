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
        message = Message.create!(permitted_params.merge(direction: :outbound_api))
        process_message(message)
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
        status: :ok,
        **serializer_options
      ) do |permitted_params|
        message.update!(body: "") if permitted_params[:redact].present?
        if permitted_params[:cancel].present?
          UpdateMessageStatus.new(message).call do
            message.cancel!
          end
        end
        message
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

    def process_message(message)
      return queue_message(message) if message.accepted?
      return send_message(message) if message.queued?

      schedule_message(message) if message.scheduled?
    end

    def queue_message(message)
      ExecuteWorkflowJob.perform_later(QueueOutboundMessage.to_s, message)
    end

    def schedule_message(message)
      ScheduledJob.perform_later(
        QueueOutboundMessage.to_s,
        message,
        wait_until: message.send_at
      )
    end

    def send_message(message)
      OutboundMessageJob.perform_later(message)
    end
  end
end
