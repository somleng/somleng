module TwilioAPI
  class BadRequestErrorSerializer < TwilioAPISerializer
    DEFAULT_ERROR_CODE = "20001".freeze
    DEFAULT_ERROR_MESSAGE = "Bad request"

    def attributes
      {
        message: nil,
        status: nil,
        code: nil,
        more_info: nil
      }
    end

    def code
      DEFAULT_ERROR_CODE
    end

    def message
      DEFAULT_ERROR_MESSAGE
    end

    def status
      400
    end

    def more_info
      "https://www.twilio.com/docs/errors/#{code}"
    end
  end
end
