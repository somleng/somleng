module Services
  class RecordingRequestSchema < ServicesRequestSchema
    params do
      required(:phone_call_id).filled(:str?)
      required(:external_id).filled(:str?)
    end

    def output
      params = super
      phone_call = PhoneCall.find(params.fetch(:phone_call_id))
      params[:account] = phone_call.account
      params
    end
  end
end
