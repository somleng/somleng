module CallService
  class Response < SimpleDelegator
    def fetch(key)
      response_body.fetch(key.to_s)
    end

    private

    def response_body
      @response_body ||= JSON.parse(body)
    end
  end
end
