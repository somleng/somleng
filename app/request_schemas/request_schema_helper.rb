class RequestSchemaHelper
  def build_schema_error(error_code)
    error = ApplicationError::Errors.fetch(error_code)
    { text: error.message, code: error.code }
  end
end
