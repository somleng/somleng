require "rails_helper"

RSpec.describe VerificationTemplate do
  describe "#render_message" do
    it "renders a message template" do
      verification_template = VerificationTemplate.new(
        friendly_name: "Rocket Rides",
        code: "123456",
        locale: :en,
        country_code: "KH"
      )

      message = verification_template.render_message

      expect(message).to eq("Your Rocket Rides verification code is: 123456.")
    end

    it "handles different locales" do
      verification_template = VerificationTemplate.new(
        friendly_name: "Rocket Rides",
        code: "123456",
        locale: :de,
        country_code: "DE"
      )

      message = verification_template.render_message

      expect(message).to eq("Dein Rocket Rides Sicherheitscode lautet: 123456.")
    end
  end

  describe "#render_voice_twiml" do
    it "renders a TwiML template" do
      verification_template = VerificationTemplate.new(
        friendly_name: "Rocket Rides",
        code: "123456",
        locale: :en,
        country_code: "KH"
      )

      twiml = verification_template.render_voice_twiml

      say_verb = twiml_verb(twiml, "Say")
      expect(say_verb.text).to eq("Your Rocket Rides verification code is: 1. 2. 3. 4. 5. 6. Again: 1. 2. 3. 4. 5. 6. One last time: 1. 2. 3. 4. 5. 6. Goodbye")
      expect(say_verb[:language]).to eq("en-US")
    end

    it "handles Brazilian Portuguese" do
      verification_template = VerificationTemplate.new(
        friendly_name: "Rocket Rides",
        code: "123456",
        locale: :"pt-br",
        country_code: "BR"
      )

      twiml = verification_template.render_voice_twiml
      say_verb = twiml_verb(twiml, "Say")

      expect(say_verb.text).to eq("O seu código de verificação para Rocket Rides é: 1. 2. 3. 4. 5. 6.")
      expect(say_verb[:language]).to eq("pt-BR")
    end

    it "handles Mexican Spanish" do
      verification_template = VerificationTemplate.new(
        friendly_name: "Rocket Rides",
        code: "123456",
        locale: :es,
        country_code: "MX"
      )

      twiml = verification_template.render_voice_twiml
      say_verb = twiml_verb(twiml, "Say")

      expect(say_verb.text).to eq("Su codigo de verificacion para Rocket Rides es: 1. 2. 3. 4. 5. 6.")
      expect(say_verb[:language]).to eq("es-MX")
    end

    it "handles French Guiana" do
      verification_template = VerificationTemplate.new(
        friendly_name: "Rocket Rides",
        code: "123456",
        locale: :fr,
        country_code: "GF"
      )

      twiml = verification_template.render_voice_twiml
      say_verb = twiml_verb(twiml, "Say")

      expect(say_verb.text).to eq("Votre code de vérification Rocket Rides est: 1. 2. 3. 4. 5. 6.")
      expect(say_verb[:language]).to eq("fr-FR")
    end
  end

  def parse_twiml_response(twiml)
    Nokogiri::XML(twiml)
  end

  def twiml_verb(twiml, verb)
    twiml_response = parse_twiml_response(twiml)
    twiml_response.at_xpath("//Response/#{verb}")
  end
end
