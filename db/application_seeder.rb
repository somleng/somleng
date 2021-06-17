class ApplicationSeeder
  USER_PASSWORD = "Somleng1234!".freeze

  def seed!
    carrier = create_carrier
    create_outbound_sip_trunk(carrier: carrier)
    account = create_account(carrier: carrier)
    phone_number = create_phone_number(carrier: carrier, account: account)
    carrier_owner = create_carrier_owner(carrier: carrier)

    puts(<<~INFO)
      Account SID:           #{account.id}
      Auth Token:            #{account.auth_token}
      Inbound Phone Number:  #{phone_number.number}
      Carrier User Email:    #{carrier_owner.email}
      Carrier User Password: #{USER_PASSWORD}
    INFO
  end

  private

  def create_carrier(params = {})
    carrier = Carrier.first_or_create!(
      params.reverse_merge(
        name: "My Carrier",
        country_code: "KH"
      )
    )

    return carrier if carrier.logo.attached?

    carrier.logo.attach(
      io: File.open(Rails.root.join("app/assets/images/logo.png")),
      filename: "photo.jpg"
    )

    carrier
  end

  def create_outbound_sip_trunk(params)
    OutboundSIPTrunk.first_or_create!(
      params.reverse_merge(
        name: "My SIP Trunk",
        host: "host.docker.internal:5061"
      )
    )
  end

  def create_account(params)
    carrier = params.fetch(:carrier)
    Account.first_or_create!(
      params.reverse_merge(
        name: carrier.name
      )
    ) do |record|
      record.build_access_token
      record.phone_numbers.build(
        number: "1234",
        voice_url: "https://demo.twilio.com/docs/voice.xml",
        voice_method: "GET",
        carrier: carrier
      )
    end
  end

  def create_phone_number(params)
    PhoneNumber.first_or_create!(
      params.reverse_merge(
        number: "1234",
        voice_url: "https://demo.twilio.com/docs/voice.xml",
        voice_method: "GET"
      )
    )
  end

  def create_carrier_owner(params)
    User.first_or_create!(
      params.reverse_merge(
        email: "user@example-carrier.com",
        name: "John Doe",
        password: USER_PASSWORD,
        carrier_role: :owner
      )
    )
  end
end
