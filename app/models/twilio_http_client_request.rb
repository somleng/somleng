require "somleng/twilio_http_client/request"

class TwilioHttpClientRequest
  def execute!(request)
    begin
      request.execute!
    rescue Timeout::Error
    end
  end
end
