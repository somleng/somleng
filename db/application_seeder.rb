class ApplicationSeeder
  USER_PASSWORD = "Somleng1234!".freeze

  def seed!
    carrier = create_carrier
    create_outbound_sip_trunk(carrier: carrier)
    account = create_account(carrier: carrier)
    carrier_user = create_carrier_user(carrier: carrier)

    puts(<<~INFO)
      Account SID:           #{account.id}
      Auth Token:            #{account.auth_token}
      Inbound Phone Number:  #{account.incoming_phone_numbers.first.phone_number}
      Carrier User Email:    #{carrier_user.email}
      Carrier User Password: #{USER_PASSWORD}
    INFO
  end

  private

  def create_carrier(params = {})
    Carrier.first_or_create!(
      params.reverse_merge(name: "My Carrier")
    )
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
      record.incoming_phone_numbers.build(
        phone_number: "1234",
        voice_url: "https://demo.twilio.com/docs/voice.xml",
        voice_method: "GET"
      )
    end
  end

  def create_carrier_user(params)
    User.first_or_create!(
      params.reverse_merge(
        email: "user@example-carrier.com",
        name: "John Doe",
        password: "Somleng1234!"
      )
    )
  end
end
