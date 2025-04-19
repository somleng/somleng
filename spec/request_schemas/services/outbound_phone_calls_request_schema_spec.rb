require "rails_helper"

module Services
  RSpec.describe OutboundPhoneCallsRequestSchema, type: :request_schema do
    it "validates destinations" do
      carrier = create(:carrier)
      account = create(:account, carrier:)
      sip_trunk = create(:sip_trunk, carrier:, outbound_route_prefixes: [ "855" ])
      parent_call = create(:phone_call, :answered, sip_trunk:, account:, carrier:)

      expect(
        validate_request_schema(
          input_params: {
            destinations: [ "+855716100235", "+855716100236" ],
            parent_call_sid: parent_call.id
          }
        )
      ).to have_valid_field(:destinations)

      expect(
        validate_request_schema(
          input_params: {
            destinations: [],
            parent_call_sid: parent_call.id
          }
        )
      ).not_to have_valid_field(:destinations)

      expect(
        validate_request_schema(
          input_params: {
            destinations: [ "16189124649" ],
            parent_call_sid: parent_call.id
          }
        )
      ).not_to have_valid_schema(error_message: ApplicationError::Errors.fetch(:calling_number_unsupported_or_invalid).message)

      expect(
        validate_request_schema(
          input_params: {
            destinations: [ "1234" ],
            parent_call_sid: parent_call.id
          }
        )
      ).not_to have_valid_schema(error_message: "1234 is invalid")
    end

    it "validates from" do
      carrier = create(:carrier)
      account = create(:account, carrier:)
      parent_call = create(:phone_call, :answered, account:, carrier:)
      create(:incoming_phone_number, account:, number: "16189124649")
      valid_attributes = { parent_call_sid: parent_call.id, destinations: [ "+855716100235" ] }

      expect(
        validate_request_schema(
          input_params: {
            from: "16189124649",
            **valid_attributes
          }
        )
      ).to have_valid_field(:from)

      expect(
        validate_request_schema(
          input_params: {
            from: nil,
            **valid_attributes
          }
        )
      ).to have_valid_field(:from)

      expect(
        validate_request_schema(
          input_params: {
            from: "1234",
            **valid_attributes
          }
        )
      ).not_to have_valid_schema(error_message: ApplicationError::Errors.fetch(:unverified_source_number).message)
    end

    it "normalizes the output" do
      carrier = create(:carrier)
      sip_trunk = create(:sip_trunk, carrier:, outbound_route_prefixes: [ "855" ])
      other_sip_trunk = create(:sip_trunk, carrier:, outbound_route_prefixes: [ "856" ])
      account = create(:account, carrier:)
      parent_call = create(
        :phone_call,
        :inbound,
        from: "855715100210",
        sip_trunk:,
        account:,
        carrier:
      )

      schema = validate_request_schema(
        input_params: {
          parent_call_sid: parent_call.id,
          from: nil,
          destinations: [
            "855715100230",
            "8562092960310"
          ]
        }
      )

      expect(schema.output).to include(
        parent_call:,
        from: have_attributes(value: "855715100210"),
        incoming_phone_number: nil,
        destinations: eq(
          [
            {
              destination: "855715100230",
              sip_trunk:
            },
            {
              destination: "8562092960310",
              sip_trunk: other_sip_trunk
            }
          ]
        )
      )
    end

    it "normalizes output for outbound calls" do
      parent_call = create(
        :phone_call,
        :outbound,
        to: "855715100210"
      )

      schema = validate_request_schema(
        input_params: {
          parent_call_sid: parent_call.id,
          from: nil,
          destinations: [
            "855715100230"
          ]
        }
      )

      expect(schema.output).to include(from: have_attributes(value: "855715100210"))
    end

    it "normalizes output for specified from values" do
      parent_call = create(
        :phone_call,
        :outbound,
        to: "855715100210"
      )
      create(:incoming_phone_number, number: "855715100210", account: parent_call.account)

      schema = validate_request_schema(
        input_params: {
          parent_call_sid: parent_call.id,
          from: "855715100210",
          destinations: [
            "855715100230"
          ]
        }
      )

      expect(schema.output).to include(from: "855715100210")
    end

    def validate_request_schema(input_params: {}, options: {})
      options.reverse_merge!(error_log_messages: ErrorLogMessages.new)
      OutboundPhoneCallsRequestSchema.new(input_params:, options:)
    end
  end
end
