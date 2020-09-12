class PhoneCallRequestSchema < ApplicationRequestSchema
  params do
    required(:To).value(ApplicationRequestSchema::Types::PhoneNumber, :filled?)
    required(:From).value(ApplicationRequestSchema::Types::PhoneNumber, :filled?)
    required(:Url).filled(:str?)
    optional(:Method).value(ApplicationRequestSchema::Types::UppercaseString, :filled?, included_in?: PhoneCall.voice_method.values)
    optional(:StatusCallback).filled(:string)
    optional(:StatusCallbackMethod).value(ApplicationRequestSchema::Types::UppercaseString, :filled?, included_in?: PhoneCall.status_callback_method.values)
  end

  def output
    params = super

    result = {
      to: params.fetch(:To),
      from: params.fetch(:From),
      voice_url: params.fetch(:Url),
      voice_method: params.fetch(:Method, "POST"),
      status_callback_url: params[:StatusCallback],
      status_callback_method: params[:SatatusCallbackMethod]
    }

    result
  end
end
