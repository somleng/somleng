module TwilioAPI
  class PhoneCallRequestSchema < TwilioAPIRequestSchema
    option :phone_number_validator, default: proc { PhoneNumberValidator.new }
    option :url_validator, default: proc { URLValidator.new(allow_http: true) }

    params do
      required(:To).value(ApplicationRequestSchema::Types::Number, :filled?)
      required(:From).value(ApplicationRequestSchema::Types::Number, :filled?)
      optional(:Url).filled(:str?)
      optional(:Method).value(
        ApplicationRequestSchema::Types::UppercaseString,
        :filled?,
        included_in?: PhoneCall.voice_method.values
      )
      optional(:StatusCallback).filled(:string)
      optional(:StatusCallbackMethod).value(
        ApplicationRequestSchema::Types::UppercaseString,
        :filled?,
        included_in?: PhoneCall.status_callback_method.values
      )
      optional(:Twiml).filled(:str?)
    end

    rule(:To) do |context:|
      next unless key?

      next key.failure("is invalid") unless phone_number_validator.valid?(value)

      destination_rules = DestinationRules.new(account:, destination: value)
      unless destination_rules.calling_code_allowed?
        next base.failure(schema_helper.build_schema_error(:call_blocked_by_blocked_list))
      end

      context[:sip_trunk] = destination_rules.sip_trunk
      if context[:sip_trunk].blank?
        next base.failure(schema_helper.build_schema_error(:calling_number_unsupported_or_invalid))
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
      next if values[:Url].blank?
      next if url_validator.valid?(values[:Url])

      key(:Url).failure("is invalid")
    end

    rule(:StatusCallback) do
      next if value.blank?
      next if url_validator.valid?(value)

      key(:StatusCallback).failure("is invalid")
    end

    def output
      params = super

      caller_id = params.fetch(:From)
      caller_id = "+#{caller_id}" if input_params.fetch(:From).starts_with?("+")

      {
        account:,
        carrier: account.carrier,
        sip_trunk: context.fetch(:sip_trunk),
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
