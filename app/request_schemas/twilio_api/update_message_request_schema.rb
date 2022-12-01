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

      base.failure(
        text: "Cannot update this resource before it is complete",
        code: "20009"
      )
    end

    rule(:Status) do
      next unless value == "canceled"
      next if message.may_cancel?

      base.failure(
        text: "Message is not in a cancelable state.",
        code: "30409"
      )
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
