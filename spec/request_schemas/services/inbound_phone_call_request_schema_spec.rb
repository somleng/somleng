require "rails_helper"

module Services
  RSpec.describe InboundPhoneCallRequestSchema, type: :request_schema do
    it "validates inbound source_ip" do
      _sip_trunk = create(:sip_trunk, inbound_source_ips: [ "175.100.7.240" ])

      expect(
        validate_request_schema(input_params: { source_ip: "175.100.7.240" })
      ).to have_valid_field(:source_ip)

      expect(
        validate_request_schema(input_params: { source_ip: "175.100.7.241" })
      ).not_to have_valid_schema(error_message: "175.100.7.241 doesn't exist")
    end

    it "validates client_identifier" do
      sip_trunk = create(:sip_trunk, :client_credentials_authentication)

      expect(
        validate_request_schema(
          input_params: { source_ip: "127.0.0.1", client_identifier: sip_trunk.username }
        )
      ).to have_valid_field(:client_identifier)

      expect(
        validate_request_schema(
          input_params: { source_ip: "127.0.0.1", client_identifier: "invalid-user" }
        )
      ).not_to have_valid_schema(error_message: "invalid-user doesn't exist")
    end

    it "validates to" do
      carrier = create(:carrier)
      account = create(:account, carrier:)
      sip_trunk = create(:sip_trunk, carrier:)
      configured_incoming_phone_number = create(
        :incoming_phone_number, :fully_configured, account:
      )
      unconfigured_incoming_phone_number = create(
        :incoming_phone_number, account:
      )

      expect(
        validate_request_schema(
          input_params: {
            to: configured_incoming_phone_number.number.to_s,
            source_ip: sip_trunk.inbound_source_ip.to_s
          }
        )
      ).to have_valid_field(:to)

      expect(
        validate_request_schema(
          input_params: {
            to: "85516701721", # unknown number
            source_ip: sip_trunk.inbound_source_ip.to_s
          }
        )
      ).not_to have_valid_schema(error_message: "Phone number 85516701721 does not exist")

      expect(
        validate_request_schema(
          input_params: {
            to: unconfigured_incoming_phone_number.number.to_s,
            source_ip: sip_trunk.inbound_source_ip.to_s
          }
        )
      ).not_to have_valid_schema(
        error_message: "Phone number #{unconfigured_incoming_phone_number.number} is unconfigured"
      )
    end

    it "validates carrier is in good standing" do
      carrier = create_restricted_carrier
      account = create(:account, carrier:)
      sip_trunk = create(:sip_trunk, carrier:)
      incoming_phone_number = create(:incoming_phone_number, :fully_configured, account:)

      expect(
        validate_request_schema(
          input_params: {
            to: incoming_phone_number.number.to_s,
            source_ip: sip_trunk.inbound_source_ip.to_s
          }
        )
      ).not_to have_valid_schema(
        error_message: ApplicationError::Errors.fetch(:carrier_standing).message
      )
    end

    it "validates from" do
      carrier = create(:carrier)
      sip_trunk = create(:sip_trunk, carrier:)
      sip_trunk_with_inbound_country = create(
        :sip_trunk, carrier:, inbound_country_code: "MX"
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
            from: "018188888888",
            source_ip: sip_trunk_with_inbound_country.inbound_source_ip.to_s
          }
        )
      ).to have_valid_field(:from)
    end

    it "normalizes the output" do
      carrier = create(:carrier)
      sip_trunk = create(:sip_trunk, :client_credentials_authentication, carrier:)
      account = create(:account, carrier:)
      incoming_phone_number = create(
        :incoming_phone_number,
        account:,
        number: "12513095500",
        voice_url: "https://demo.twilio.com/docs/voice.xml",
        voice_method: "GET",
        status_callback_url: "https://example.com/status-callback",
        status_callback_method: "POST"
      )

      schema = validate_request_schema(
        input_params: {
          source_ip: "127.0.0.1",
          client_identifier: sip_trunk.username,
          to: "12513095500",
          from: "855716100230",
          external_id: "external-id",
          host: "10.10.1.13",
          variables: {
            "sip_from_host" => "103.9.189.2"
          }
        }
      )

      expect(schema.output).to include(
        account:,
        to: "12513095500",
        from: "855716100230",
        external_id: "external-id",
        incoming_phone_number:,
        phone_number: incoming_phone_number.phone_number,
        sip_trunk:,
        voice_url: "https://demo.twilio.com/docs/voice.xml",
        voice_method: "GET",
        status_callback_url: "https://example.com/status-callback",
        status_callback_method: "POST",
        call_service_host: "10.10.1.13",
        variables: {
          "sip_from_host" => "103.9.189.2"
        }
      )
    end

    it "normalizes from with an inbound country configured" do
      carrier = create(:carrier)
      account = create(:account, carrier:)
      _sip_trunk = create(
        :sip_trunk,
        carrier:,
        inbound_source_ip: "175.100.7.240",
        inbound_country_code: "KH"
      )
      _incoming_phone_number = create(
        :incoming_phone_number,
        type: :short_code,
        number: "1294",
        account:
      )
      schema = validate_request_schema(
        input_params: {
          source_ip: "175.100.7.240",
          to: "1294",
          from: "068308531",
          external_id: "external-id",
          host: "10.10.1.13"
        }
      )

      expect(schema.output).to include(from: "85568308531", to: "1294")
    end

    it "normalizes to with an inbound country configured" do
      carrier = create(:carrier)
      account = create(:account, carrier:)
      _sip_trunk = create(
        :sip_trunk,
        carrier:,
        inbound_source_ip: "175.100.7.240",
        inbound_country_code: "LA"
      )
      _incoming_phone_number = create(
        :incoming_phone_number,
        number: "8562092960310",
        account:
      )
      schema = validate_request_schema(
        input_params: {
          source_ip: "175.100.7.240",
          to: "02092960310",
          from: "02092960314",
          external_id: "external-id",
          host: "10.10.1.13"
        }
      )

      expect(schema.output).to include(from: "8562092960314", to: "8562092960310")
    end

    it "normalizes the twiml for routing to a sip domain" do
      carrier = create(:carrier)
      account = create(:account, carrier:)
      sip_trunk = create(:sip_trunk, carrier:)
      incoming_phone_number = create(
        :incoming_phone_number,
        account:,
        number: "2442",
        type: :short_code,
        sip_domain: "example.sip.twilio.com"
      )
      schema = validate_request_schema(
        input_params: {
          source_ip: sip_trunk.inbound_source_ip.to_s,
          to: incoming_phone_number.number.to_s,
          from: "855716100230",
          external_id: "external-id",
          host: "10.10.1.13"
        }
      )

      expect(schema.output).to include(
        voice_url: nil,
        twiml: include("sip:2442@example.sip.twilio.com")
      )
    end

    def validate_request_schema(input_params: {}, options: {})
      options.reverse_merge!(error_log_messages: ErrorLogMessages.new)
      InboundPhoneCallRequestSchema.new(input_params:, options:)
    end
  end
end
