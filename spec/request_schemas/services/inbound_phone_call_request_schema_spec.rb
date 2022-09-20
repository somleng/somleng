require "rails_helper"

module Services
  RSpec.describe InboundPhoneCallRequestSchema, type: :request_schema do
    it "validates inbound source_ip" do
      _sip_trunk = create(:sip_trunk, inbound_source_ip: "175.100.7.240")

      expect(
        validate_request_schema(input_params: { source_ip: "175.100.7.240" })
      ).to have_valid_field(:source_ip)

      expect(
        validate_request_schema(input_params: { source_ip: "175.100.7.241" })
      ).not_to have_valid_schema(error_message: "175.100.7.241 doesn't exist")
    end

    it "validates username" do
      sip_trunk = create(:sip_trunk, :client_credentials_authentication)

      expect(
        validate_request_schema(
          input_params: { source_ip: "127.0.0.1", username: sip_trunk.username }
        )
      ).to have_valid_field(:username)

      expect(
        validate_request_schema(
          input_params: { source_ip: "127.0.0.1", username: "invalid-user" }
        )
      ).not_to have_valid_schema(error_message: "invalid-user doesn't exist")
    end

    it "validates to" do
      carrier = create(:carrier)
      sip_trunk = create(:sip_trunk, carrier:)
      unassigned_phone_number = create(:phone_number, carrier:)
      configured_phone_number = create(
        :phone_number, :configured, :assigned_to_account, carrier:
      )
      unconfigured_phone_number = create(
        :phone_number, :assigned_to_account, carrier:
      )
      disabled_phone_number = create(
        :phone_number, :configured, :disabled, :assigned_to_account, carrier:
      )

      expect(
        validate_request_schema(
          input_params: {
            to: configured_phone_number.number,
            source_ip: sip_trunk.inbound_source_ip.to_s
          }
        )
      ).to have_valid_field(:to)

      expect(
        validate_request_schema(
          input_params: {
            to: unassigned_phone_number.number,
            source_ip: sip_trunk.inbound_source_ip.to_s
          }
        )
      ).not_to have_valid_field(:to, error_message: "is unassigned")

      expect(
        validate_request_schema(
          input_params: {
            to: "85516701721", # unknown number
            source_ip: sip_trunk.inbound_source_ip.to_s
          }
        )
      ).not_to have_valid_field(:to)

      expect(
        validate_request_schema(
          input_params: {
            to: unconfigured_phone_number.number,
            source_ip: sip_trunk.inbound_source_ip.to_s
          }
        )
      ).not_to have_valid_field(:to, error_message: "is unconfigured")

      expect(
        validate_request_schema(
          input_params: {
            to: disabled_phone_number.number,
            source_ip: sip_trunk.inbound_source_ip.to_s
          }
        )
      ).not_to have_valid_field(:to, error_message: "is disabled")
    end

    it "validates carrier is in good standing" do
      carrier = create_restricted_carrier
      sip_trunk = create(:sip_trunk, carrier:)
      phone_number = create(:phone_number, carrier:)

      expect(
        validate_request_schema(
          input_params: {
            to: phone_number.number,
            source_ip: sip_trunk.inbound_source_ip.to_s
          }
        )
      ).not_to have_valid_schema(error_message: "carrier is not in good standing")
    end

    it "validates from" do
      carrier = create(:carrier)
      sip_trunk = create(:sip_trunk, carrier:)
      sip_trunk_with_trunk_prefix_replacement = create(
        :sip_trunk, carrier:, inbound_trunk_prefix_replacement: "52"
      )

      expect(
        validate_request_schema(
          input_params: {
            from: "abc",
            source_ip: sip_trunk.inbound_source_ip.to_s
          }
        )
      ).not_to have_valid_field(:from)

      expect(
        validate_request_schema(
          input_params: {
            from: "8188888888",
            source_ip: sip_trunk.inbound_source_ip.to_s
          }
        )
      ).not_to have_valid_field(:from)

      expect(
        validate_request_schema(
          input_params: {
            from: "8188888888",
            source_ip: sip_trunk_with_trunk_prefix_replacement.inbound_source_ip.to_s
          }
        )
      ).to have_valid_field(:from)
    end

    it "normalizes the output" do
      carrier = create(:carrier)
      sip_trunk = create(:sip_trunk, :client_credentials_authentication, carrier:)
      account = create(:account)
      phone_number = create(:phone_number, account:, carrier:, number: "2442")
      create(
        :phone_number_configuration,
        phone_number:,
        voice_url: "https://demo.twilio.com/docs/voice.xml",
        voice_method: "GET",
        status_callback_url: "https://example.com/status-callback",
        status_callback_method: "POST"
      )

      schema = validate_request_schema(
        input_params: {
          source_ip: "127.0.0.1",
          username: sip_trunk.username,
          to: "2442",
          from: "855716100230",
          external_id: "external-id",
          variables: {
            "sip_from_host" => "103.9.189.2"
          }
        }
      )

      expect(schema.output).to include(
        account:,
        to: "2442",
        from: "855716100230",
        external_id: "external-id",
        phone_number:,
        sip_trunk:,
        voice_url: "https://demo.twilio.com/docs/voice.xml",
        voice_method: "GET",
        status_callback_url: "https://example.com/status-callback",
        status_callback_method: "POST",
        variables: {
          "sip_from_host" => "103.9.189.2"
        }
      )
    end

    it "normalizes the from for accounts with a trunk prefix replacement" do
      carrier = create(:carrier)
      _sip_trunk = create(
        :sip_trunk,
        carrier:,
        inbound_source_ip: "175.100.7.240",
        inbound_trunk_prefix_replacement: "855"
      )
      _phone_number = create(
        :phone_number,
        :configured,
        number: "855716100235",
        carrier:
      )
      schema = validate_request_schema(
        input_params: {
          source_ip: "175.100.7.240",
          to: "855716100235",
          from: "0716100230",
          external_id: "external-id"
        }
      )

      expect(schema.output).to include(from: "855716100230")
    end

    it "normalizes the twiml for routing to a sip domain" do
      carrier = create(:carrier)
      sip_trunk = create(:sip_trunk, carrier:)
      account = create(:account)
      phone_number = create(
        :phone_number,
        account:,
        carrier:,
        number: "2442"
      )
      create(
        :phone_number_configuration,
        phone_number:,
        voice_url: nil,
        voice_method: nil,
        sip_domain: "example.sip.twilio.com"
      )
      schema = validate_request_schema(
        input_params: {
          source_ip: sip_trunk.inbound_source_ip.to_s,
          to: phone_number.number,
          from: "855716100230",
          external_id: "external-id"
        }
      )

      expect(schema.output).to include(
        voice_url: nil,
        voice_method: nil,
        twiml: include("sip:2442@example.sip.twilio.com")
      )
    end

    def validate_request_schema(input_params: {}, options: {})
      options.reverse_merge!(error_log_messages: ErrorLogMessages.new)
      InboundPhoneCallRequestSchema.new(input_params:, options:)
    end
  end
end
