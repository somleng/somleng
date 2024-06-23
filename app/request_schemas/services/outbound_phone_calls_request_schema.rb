module Services
  class OutboundPhoneCallsRequestSchema < ServicesRequestSchema
    option :error_log_messages
    option :phone_number_validator, default: -> { PhoneNumberValidator.new }
    option :phone_call_destination_schema_rules, default: -> { SchemaRules::PhoneCallDestinationSchemaRules.new }
    option :phone_number_configuration_rules, default: -> { PhoneNumberConfigurationRules.new }

    params do
      required(:parent_call_sid).filled(:str?)
      required(:destinations).array(ApplicationRequestSchema::Types::Number, :filled?)
      optional(:from).maybe(ApplicationRequestSchema::Types::Number)
    end

    rule do |context:|
      next key(:destinations).failure(schema_helper.build_schema_error(:invalid_parameter, text: "is blank")) if values[:destinations].blank?
      parent_call = PhoneCall.find_by(id: values[:parent_call_sid])
      next key(:parent_call_sid).failure(schema_helper.build_schema_error(:invalid_parameter, text: "is invalid")) if parent_call.blank?
      context[:parent_call] = parent_call

      context[:from], context[:incoming_phone_number], error = validate_from(from: values[:from], parent_call: parent_call)

      next key(:from).failure(error) if error.present?

      context[:destinations], error = validate_destinations(
        account: context[:parent_call].account,
        destinations: values.fetch(:destinations)
      )

      key(:destinations).failure(error) if error.present?
    end

    def output
      {
        parent_call: context.fetch(:parent_call),
        from: context.fetch(:from),
        incoming_phone_number: context.fetch(:incoming_phone_number),
        destinations: context.fetch(:destinations)
      }
    end

    private

    def validate_destinations(account:, destinations:)
      valid_destinations = destinations.each_with_object([]) do |destination, result|
        return [
          nil,
          schema_helper.build_schema_error(:invalid_parameter, text: "#{destination} is invalid")
        ] unless phone_number_validator.valid?(destination)

        if phone_call_destination_schema_rules.valid?(account:, destination:)
          result << { destination:, sip_trunk: phone_call_destination_schema_rules.sip_trunk }
        else
          error = schema_helper.build_schema_error(phone_call_destination_schema_rules.error_code)
          return [ nil, error ]
        end
      end

      [ valid_destinations ]
    end

    def validate_from(from:, parent_call:)
      return parent_call.inbound? ? parent_call.from : parent_call.to if from.blank?

      incoming_phone_number = parent_call.account.incoming_phone_numbers.active.find_by(number: from)
      phone_number_configuration_rules.valid?(incoming_phone_number) ? [ from, incoming_phone_number ] : [ nil, nil, schema_helper.build_schema_error(:unverified_source_number) ]
    end
  end
end
