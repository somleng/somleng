class JSONAPIRequestSchemaErrorsSerializer < JSONAPIErrorsSerializer
  private

  def build_error(error)
    {
      title: error.text,
      source: {
        pointer: "/#{error.path.join('/')}"
      },
      **error.meta.slice(:code, :detail)
    }
  end
end
