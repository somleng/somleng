module TwilioAPI
  class RequestErrorsSerializer < TwilioAPISerializer
    DEFAULT_ERROR_CODE = "20422".freeze

    def attributes
      {
        message: nil,
        status: nil,
        code: nil,
        more_info: nil
      }
    end

    def message
      errors(full: true).map(&:text).to_sentence
    end

    def status
      422
    end

    def code
      errors.each do |error|
        return error.meta.fetch(:code) if error.meta.key?(:code)
      end

      DEFAULT_ERROR_CODE
    end

    def more_info
      "https://www.twilio.com/docs/errors/#{code}"
    end
  end
end
