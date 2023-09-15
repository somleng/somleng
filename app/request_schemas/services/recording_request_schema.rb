module Services
  class RecordingRequestSchema < ServicesRequestSchema
    option :url_validator, default: proc { URLValidator.new(allow_http: true) }

    params do
      required(:phone_call_id).filled(:str?)
      optional(:status_callback_url).filled(:str?)
      optional(:status_callback_method).value(
        ApplicationRequestSchema::Types::UppercaseString,
        :filled?,
        included_in?: Recording.status_callback_method.values
      )
    end

    rule(:status_callback_url) do
      next if value.blank?
      next if url_validator.valid?(value)

      key(:status_callback_url).failure("is invalid")
    end

    def output
      params = super
      phone_call = PhoneCall.find(params.delete(:phone_call_id))
      params[:phone_call] = phone_call
      params[:account] = phone_call.account
      params[:status_callback_method] ||= "POST" if params.key?(:status_callback_url)
      params
    end
  end
end
