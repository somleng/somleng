module CallService
  class Client
    def create_call(params)
      execute_request(:post, "/calls", params)
    end

    def end_call(id)
      execute_request(:delete, "/calls/#{id}")
    end

    private

    def execute_request(http_method, url, params = {}, headers = {})
      response = http_client.run_request(http_method, url, params.to_json, headers)

      Response.new(response)
    end

    def http_client
      @http_client ||= Faraday.new(url: CallService.configuration.host) do |conn|
        conn.headers["Accept"] = "application/json"
        conn.headers["Content-Type"] = "application/json"

        conn.adapter Faraday.default_adapter

        conn.request :basic_auth, CallService.configuration.username, CallService.configuration.password
      end
    end
  end
end
