class ApplicationSeeder
  def seed!
    carrier = Carrier.first_or_create!(name: "Test Carrier")

    account = Account.first_or_create!(carrier: carrier) do |record|
      record.build_access_token
      record.incoming_phone_numbers.build(
        phone_number: "1234",
        voice_url: "https://demo.twilio.com/docs/voice.xml",
        voice_method: "GET"
      )
    end

    puts(<<~INFO)
      Account SID:          #{account.id}
      Auth Token:           #{account.auth_token}
      Inbound Phone Number: #{account.incoming_phone_numbers.first.phone_number}
    INFO
  end
end
