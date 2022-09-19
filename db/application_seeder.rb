class ApplicationSeeder
  USER_PASSWORD = "Somleng1234!".freeze

  def seed!
    carrier = Carrier.first
    carrier ||= OnboardCarrier.call(
      name: "My Carrier",
      country_code: "KH",
      restricted: false,
      subdomain: "my-carrier",
      website: "https://example.com",
      owner: {
        email: "johndoe@carrier.com",
        name: "John Doe",
        password: USER_PASSWORD,
        carrier_role: :owner,
        confirmed_at: Time.current
      }
    )
    create_sip_trunk(carrier:)
    account = create_account(carrier:)
    phone_number = create_phone_number(carrier:, account:)

    puts(<<~INFO)
      Account SID:           #{account.id}
      Auth Token:            #{account.auth_token}
      Inbound Phone Number:  #{phone_number.number}
      ---------------------------------------------
      URL:                   #{url_helpers.dashboard_root_url(host: carrier.subdomain_host)}
      Carrier User Email:    #{carrier.carrier_users.first.email}
      Carrier User Password: #{USER_PASSWORD}
      Carrier API Key:       #{carrier.api_key}
    INFO
  end

  private

  def create_sip_trunk(params)
    SIPTrunk.first_or_create!(
      params.reverse_merge(
        name: "My SIP Trunk",
        outbound_host: "host.docker.internal:5061",
        inbound_source_ip: ENV.fetch("HOST_IP", "127.0.0.1"),
        authentication_mode: :ip_address
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

  def url_helpers
    @url_helpers ||= Rails.application.routes.url_helpers
  end
end
