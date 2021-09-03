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

    rule(:To) do |context:|
      next if schema_error?(:To)

      destination_rules = DestinationRules.new(account: account, destination: value)
      unless destination_rules.calling_code_allowed?
        next base.failure(text: "Call blocked by block list", code: "13225")
      end

      context[:outbound_sip_trunk] = destination_rules.find_sip_trunk
      if context[:outbound_sip_trunk].blank?
        base.failure(
          text: "Calling this number is unsupported or the number is invalid",
          code: "13224"
        )
      end
    end

    rule(:Twiml) do
      Nokogiri::XML(value) { |c| c.options = Nokogiri::XML::ParseOptions::STRICT } if key? && value.present?
    rescue Nokogiri::XML::SyntaxError
      key.failure("is invalid")
    end

    rule(:Url, :Twiml) do
      key(:Url).failure("is required") unless key?(:Url) || key?(:Twiml)
    end

    def output
      params = super

      {
        account: account,
        carrier: account.carrier,
        outbound_sip_trunk: context.fetch(:outbound_sip_trunk),
        dial_string: DialString.new(
          outbound_sip_trunk: context.fetch(:outbound_sip_trunk),
          destination: params.fetch(:To)
        ).to_s,
        to: params.fetch(:To),
        from: params.fetch(:From),
        voice_url: params[:Url],
        voice_method: params.fetch(:Method) { "POST" if params.key?(:Url) },
        status_callback_url: params[:StatusCallback],
        status_callback_method: params[:StatusCallbackMethod],
        twiml: (params[:Twiml] unless params.key?(:Url)),
        direction: :outbound
      }
    end
  end
end
