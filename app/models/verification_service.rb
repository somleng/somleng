class VerificationService < ApplicationRecord
  class DefaultTemplate
    attr_reader :friendly_name, :code, :locale

    def initialize(friendly_name:, code:, locale:)
      @friendly_name = friendly_name
      @code = code
      @locale = locale
    end

    def render_message
      generate_message(code:)
    end

    def render_voice_twiml
      message = generate_message(code: code_with_punctuation)
      response = Twilio::TwiML::VoiceResponse.new
      response.say(message:)
      response.to_xml
    end

    private

    def code_with_punctuation
      code.chars.join(". ")
    end

    def generate_message(code:)
      fallback = I18n.t(:"verification_templates.default", friendly_name:, code:)
      I18n.t(
        :"verification_templates.default",
        friendly_name:, code:, locale:, default: fallback
      )
    end
  end

  belongs_to :carrier
  belongs_to :account

  has_many :verifications

  def default_template(code:, locale:)
    DefaultTemplate.new(friendly_name: name, locale:, code:)
  end
end
