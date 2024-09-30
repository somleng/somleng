class SomlengSlateExample < RspecApiDocumentation::Views::SlateExample
  def requests
    super.map do |hash|
      hash[:request_query_parameters_text] = JSON.pretty_generate(hash[:request_query_parameters])
      hash
    end
  end
end
