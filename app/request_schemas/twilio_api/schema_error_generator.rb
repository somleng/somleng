module TwilioAPI
  class SchemaErrorGenerator
    def build(error)
      error = Errors.fetch(error)
      { text: error.message, code: error.code }
    end
  end
end
