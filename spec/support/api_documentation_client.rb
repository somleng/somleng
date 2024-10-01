class APIDocumentationClient < RspecApiDocumentation::RackTestClient
  class Curl < RspecApiDocumentation::Curl
    LINE_JOINER = " \\\n\t".freeze

    attr_accessor :content_type, :docs_group

    def post
      return super unless content_type == "application/x-www-form-urlencoded"

      post_data = Rack::Utils.parse_query(data).each_with_object([]) do |(key, value), result|
        result << "--data-urlencode \"#{key}=#{value}\""
      end.join(LINE_JOINER)

      headers_and_post_data = [ headers, post_data.presence ].compact.join(LINE_JOINER)

      "curl -X POST \"#{url}\" #{headers_and_post_data}"
    end

    def get
      "curl \"#{url}#{get_data}\" #{headers}"
    end

    private

    def format_auth_header(...)
      result = super

      return result unless docs_group == :twilio_api

      account_sid, _auth_token = result.split(":", 2)

      "#{account_sid}:AuthToken"
    end
  end

  def document_example(...)
    requests = super
    return if requests.blank?

    request_metadata = requests.last

    request_metadata[:curl] = build_curl(request_metadata)
    request_metadata[:curl].docs_group = metadata[:document]

    if request_metadata[:request_content_type] == "application/x-www-form-urlencoded"
      request_metadata[:request_body] = JSON.pretty_generate(Rack::Utils.parse_query(request_metadata.fetch(:request_body)))
    end

    requests
  end

  private

  def build_curl(request_metadata)
    curl = Curl.new(
      request_metadata.fetch(:request_method),
      request_metadata.fetch(:request_path),
      request_metadata.fetch(:request_body),
      request_metadata.fetch(:request_headers)
    )
    curl.content_type = request_metadata.fetch(:request_content_type)
    curl
  end

  # https://github.com/zipmark/rspec_api_documentation/pull/543/files
  def read_request_body
    input = last_request.env["rack.input"] || StringIO.new
    input.rewind
    input.read
  end
end
