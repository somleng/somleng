module TwilioAPI
  class PhoneCallRequestSchema < TwilioAPIRequestSchema
    option :phone_number_validator, default: -> { PhoneNumberValidator.new }
    option :url_validator, default: -> { URLValidator.new(allow_http: true) }
    option :phone_call_destination_schema_rules, default: -> { PhoneCallDestinationSchemaRules.new }

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

      phone_call_destination_schema_rules.account = account
      phone_call_destination_schema_rules.destination = value

      if phone_call_destination_schema_rules.valid?
        context[:sip_trunk] = phone_call_destination_schema_rules.sip_trunk
      else
        base.failure(schema_helper.build_schema_error(phone_call_destination_schema_rules.error_code))
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
