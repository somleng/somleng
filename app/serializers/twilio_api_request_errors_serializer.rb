class TwilioAPIRequestErrorsSerializer < ApplicationSerializer
  def attributes
    {
      message: nil,
      status: nil,
      code: nil,
      more_info: nil
    }
  end

  def message
    errors(full: true).to_h.values.flatten.to_sentence
  end

  def status
    422
  end

  def code
    20422
  end

  def more_info
    "https://www.twilio.com/docs/errors/20422"
  end
end
