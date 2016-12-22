class Api::BaseResponder < ActionController::Responder
  def json_resource_errors
    super.merge(twilio_unprocessable_entity_error)
  end

  def twilio_unprocessable_entity_error(options = {})
    Twilio::ApiError::UnprocessableEntity.new(
      {
        :message => resource.errors.full_messages.to_sentence
      }.merge(options)
    ).to_hash
  end
end
