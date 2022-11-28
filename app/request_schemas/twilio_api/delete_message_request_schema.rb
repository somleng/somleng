module TwilioAPI
  class DeleteMessageRequestSchema < TwilioAPIRequestSchema
    option :message

    params {}

    rule do
      next if message.complete?

      base.failure(
        text: "Cannot delete this resource before it is complete",
        code: "20009"
      )
    end
  end
end
