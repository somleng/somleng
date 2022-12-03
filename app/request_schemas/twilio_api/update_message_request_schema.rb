module TwilioAPI
  class UpdateMessageRequestSchema < TwilioAPIRequestSchema
    option :message

    params do
      optional(:Body).value(:string, eql?: "")
      optional(:Status).value(:string, eql?: "canceled")
    end

    rule(:Body) do
      next unless value == ""
      next if message.complete?

      base.failure(schema_helper.build_schema_error(:update_before_complete))
    end

    rule(:Status) do
      next unless value == "canceled"
      next if message.may_cancel?

      base.failure(schema_helper.build_schema_error(:message_not_cancelable))
    end

    def output
      params = super

      result = {}
      result[:redact] = true if params[:Body] == ""
      result[:cancel] = true if params[:Status] == "canceled"
      result
    end
  end
end
