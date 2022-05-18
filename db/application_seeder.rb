class ApplicationSeeder
  USER_PASSWORD = "Somleng1234!".freeze

  def seed!
    carrier = Carrier.first
    carrier ||= OnboardCarrier.call(
      name: "My Carrier",
      country_code: "KH",
      restricted: false,
      website: "https://example.com",
      owner: {
        email: "johndoe@carrier.com",
        name: "John Doe",
        password: USER_PASSWORD,
        carrier_role: :owner,
        confirmed_at: Time.current
      }
    )
    create_outbound_sip_trunk(carrier:)
    create_inbound_sip_trunk(carrier:)
    account = create_account(carrier:)
    phone_number = create_phone_number(carrier:, account:)

    puts(<<~INFO)
      Account SID:           #{account.id}
      Auth Token:            #{account.auth_token}
      Inbound Phone Number:  #{phone_number.number}
      ---------------------------------------------
      Carrier User Email:    #{carrier.carrier_users.first.email}
      Carrier User Password: #{USER_PASSWORD}
      Carrier API Key:       #{carrier.api_key}
    INFO
  end

  private

  def create_outbound_sip_trunk(params)
    OutboundSIPTrunk.first_or_create!(
      params.reverse_merge(
        name: "My SIP Trunk",
        host: "host.docker.internal:5061"
      )
    )
  end

  def create_inbound_sip_trunk(params)
    InboundSIPTrunk.first_or_create!(
      params.reverse_merge(
        name: "My SIP Trunk",
        source_ip: ENV.fetch("HOST_IP", "127.0.0.1")
      )
    )
  end

  def create_account(params)
    carrier = params.fetch(:carrier)
    Account.first_or_create!(params.reverse_merge(name: carrier.name), &:build_access_token)
  end

  def create_phone_number(params)
    PhoneNumber.first_or_create!(
      params.reverse_merge(number: "1234")
    ) do |record|
      record.build_configuration(
        voice_url: "https://demo.twilio.com/docs/voice.xml",
        voice_method: "GET"
      )
    end
  end
end
