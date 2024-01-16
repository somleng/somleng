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
      expect(say_verb.text).to eq("Your Rocket Rides verification code is: 1, 2, 3, 4, 5, 6. Again: 1, 2, 3, 4, 5, 6. One last time: 1, 2, 3, 4, 5, 6. Goodbye")
      expect(say_verb[:language]).to eq("en-US")
      assert_tts_voice_exists_for("en-US")
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

      expect(say_verb.text).to eq("O seu código de verificação para Rocket Rides é: 1, 2, 3, 4, 5, 6.")
      expect(say_verb[:language]).to eq("pt-BR")
      assert_tts_voice_exists_for("pt-BR")
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

      expect(say_verb.text).to eq("Su codigo de verificacion para Rocket Rides es: 1, 2, 3, 4, 5, 6.")
      expect(say_verb[:language]).to eq("es-MX")
      assert_tts_voice_exists_for("es-MX")
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

      expect(say_verb.text).to eq("Votre code de vérification Rocket Rides est: 1, 2, 3, 4, 5, 6.")
      expect(say_verb[:language]).to eq("fr-FR")
      assert_tts_voice_exists_for("fr-FR")
    end

    it "handles Chinese Mandarin" do
      verification_template = VerificationTemplate.new(
        friendly_name: "Rocket Rides",
        code: "123456",
        locale: :zh,
        country_code: "CN"
      )

      twiml = verification_template.render_voice_twiml
      say_verb = twiml_verb(twiml, "Say")

      expect(say_verb.text).to eq("您的 Rocket Rides 验证代码是：1, 2, 3, 4, 5, 6.")
      expect(say_verb[:language]).to eq("cmn-CN")
      assert_tts_voice_exists_for("cmn-CN")
    end

    it "handles Chinese Cantonese" do
      verification_template = VerificationTemplate.new(
        friendly_name: "Rocket Rides",
        code: "123456",
        locale: :"zh-hk",
        country_code: "CN"
      )

      twiml = verification_template.render_voice_twiml
      say_verb = twiml_verb(twiml, "Say")

      expect(say_verb.text).to eq("您的 Rocket Rides 驗證代碼是：1, 2, 3, 4, 5, 6.")
      expect(say_verb[:language]).to eq("yue-CN")
      assert_tts_voice_exists_for("yue-CN")
    end

    it "handles Gulf Arabic" do
      verification_template = VerificationTemplate.new(
        friendly_name: "Rocket Rides",
        code: "123456",
        locale: :ar,
        country_code: "AE"
      )

      twiml = verification_template.render_voice_twiml
      say_verb = twiml_verb(twiml, "Say")

      expect(say_verb.text).to eq("‫رمز تعريفك الخاص ب Rocket Rides هو 1, 2, 3, 4, 5, 6‬")
      expect(say_verb[:language]).to eq("ar-AE")
      assert_tts_voice_exists_for("ar-AE")
    end

    it "handles Algerian Arabic" do
      verification_template = VerificationTemplate.new(
        friendly_name: "Rocket Rides",
        code: "123456",
        locale: :ar,
        country_code: "AZ"
      )

      twiml = verification_template.render_voice_twiml
      say_verb = twiml_verb(twiml, "Say")

      expect(say_verb.text).to eq("‫رمز تعريفك الخاص ب Rocket Rides هو 1, 2, 3, 4, 5, 6‬")
      expect(say_verb[:language]).to eq("arb")
      assert_tts_voice_exists_for("arb")
    end
  end

  def parse_twiml_response(twiml)
    Nokogiri::XML(twiml)
  end

  def twiml_verb(twiml, verb)
    twiml_response = parse_twiml_response(twiml)
    twiml_response.at_xpath("//Response/#{verb}")
  end

  def assert_tts_voice_exists_for(language)
    expect(TTSVoices::Voice.all.map(&:language)).to include(language)
  end
end
