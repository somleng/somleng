module TwilioAPI
  class PhoneCallRequestSchema < TwilioAPIRequestSchema
    params do
      required(:To).value(ApplicationRequestSchema::Types::PhoneNumber, :filled?)
      required(:From).value(ApplicationRequestSchema::Types::Number, :filled?)
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

      destination_rules = DestinationRules.new(account:, destination: value)
      unless destination_rules.calling_code_allowed?
        next base.failure(text: "Call blocked by block list", code: "13225")
      end

      context[:sip_trunk] = destination_rules.sip_trunk
      if context[:sip_trunk].blank?
        base.failure(
          text: "Calling this number is unsupported or the number is invalid",
          code: "13224"
        )
      end
    end

    rule(:Twiml) do
      if key? && value.present?
        Nokogiri::XML(value) do |c|
          c.options = Nokogiri::XML::ParseOptions::STRICT
        end
      end
    rescue Nokogiri::XML::SyntaxError
      key.failure("is invalid")
    end

    rule(:Url, :Twiml) do
      key(:Url).failure("is required") unless key?(:Url) || key?(:Twiml)
    end

    def output
      params = super

      caller_id = params.fetch(:From)
      caller_id = "+#{caller_id}" if input_params.fetch(:From).starts_with?("+")

      {
        account:,
        carrier: account.carrier,
        sip_trunk: context.fetch(:sip_trunk),
        dial_string: DialString.new(
          sip_trunk: context.fetch(:sip_trunk),
          destination: params.fetch(:To)
        ).to_s,
        to: params.fetch(:To),
        from: params.fetch(:From),
        caller_id:,
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
