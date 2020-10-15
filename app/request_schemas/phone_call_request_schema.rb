class PhoneCallRequestSchema < ApplicationRequestSchema
  URL_FORMAT = /\A#{URI::DEFAULT_PARSER.make_regexp(%w[http https])}\z/.freeze

  params do
    required(:To).value(ApplicationRequestSchema::Types::PhoneNumber, :filled?)
    required(:From).value(ApplicationRequestSchema::Types::PhoneNumber, :filled?)
    required(:Url).filled(:str?, format?: URL_FORMAT)
    optional(:Method).value(
      ApplicationRequestSchema::Types::UppercaseString,
      :filled?,
      included_in?: PhoneCall.voice_method.values
    )
    optional(:StatusCallback).filled(:string, format?: URL_FORMAT)
    optional(:StatusCallbackMethod).value(
      ApplicationRequestSchema::Types::UppercaseString,
      :filled?,
      included_in?: PhoneCall.status_callback_method.values
    )
  end

  rule(:To).validate(:phone_number_format)

  def output
    params = super

    {
      to: params.fetch(:To),
      from: params.fetch(:From),
      voice_url: params.fetch(:Url),
      voice_method: params.fetch(:Method, "POST"),
      status_callback_url: params[:StatusCallback],
      status_callback_method: params[:SatatusCallbackMethod],
      direction: :outbound
    }
  end
end
