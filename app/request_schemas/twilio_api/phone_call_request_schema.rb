module TwilioAPI
  class PhoneCallRequestSchema < TwilioAPIRequestSchema
    URL_FORMAT = /\A#{URI::DEFAULT_PARSER.make_regexp(%w[http https])}\z/.freeze

    params do
      required(:To).value(ApplicationRequestSchema::Types::PhoneNumber, :filled?)
      required(:From).value(ApplicationRequestSchema::Types::PhoneNumber, :filled?)
      optional(:Url).filled(:str?, format?: URL_FORMAT)
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
      optional(:Twiml).filled(:str?)
    end

    rule(:To).validate(:phone_number_format)

    rule(:Twiml) do
      Nokogiri::XML(value) { |c| c.options = Nokogiri::XML::ParseOptions::STRICT } if key? && value.present?
    rescue Nokogiri::XML::SyntaxError
      key.failure("is invalid")
    end

    rule(:Url, :Twiml) do
      if !(key?(:Url) || key?(:Twiml))
        key(:Url).failure("is required")
      end
    end

    def output
      params = super

      {
        to: params.fetch(:To),
        from: params.fetch(:From),
        voice_url: params[:Url],
        voice_method: params.fetch(:Method) { "POST" if params.key?(:Url) },
        status_callback_url: params[:StatusCallback],
        status_callback_method: params[:SatatusCallbackMethod],
        twiml: (params[:Twiml] unless params.key?(:Url)),
        direction: :outbound
      }
    end
  end
end
