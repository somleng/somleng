module TwilioAPI
  class SchemaErrorGenerator
    def generate_for(error_context, error:)
      error_context.failure(text: error.message, code: error.code)
    end
  end
end
