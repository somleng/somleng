class APIRequestErrorsSerializer < ApplicationSerializer
  def serializable_hash(_options = nil)
    {
      message: object.errors(full: true).to_h.values.flatten.to_sentence,
      status: 422,
      code: 20422,
      more_info: "https://www.twilio.com/docs/errors/20422"
    }
  end
end
