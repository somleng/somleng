class RequestSchemaHelper
  def build_schema_error(error_code)
    error = fetch_error(error_code)
    { text: error.message, code: error.code }
  end

  def fetch_error(error_code)
    ApplicationError::Errors.fetch(error_code)
  end
end
