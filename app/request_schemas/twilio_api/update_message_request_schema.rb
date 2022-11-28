module TwilioAPI
  class UpdateMessageRequestSchema < TwilioAPIRequestSchema
    option :message

    params do
      optional(:Body).value(:string, eql?: "")
    end

    rule do
      next if message.completed?

      base.failure(
        text: "Cannot update this resource before it is complete",
        code: "20009"
      )
    end

    def output
      params = super

      {
        body: params.fetch(:Body)
      }
    end
  end
end
