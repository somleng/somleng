module TwilioAPI
  class DeleteMessageRequestSchema < TwilioAPIRequestSchema
    option :message

    params { }

    rule do
      next if message.complete?

      base.failure(schema_helper.build_schema_error(:delete_before_complete))
    end
  end
end
