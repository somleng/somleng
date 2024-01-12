class VerificationTemplate
  DEFAULT_VOICE_LANGUAGE = "en-US".freeze

  attr_reader :friendly_name, :code, :locale, :country_code, :template

  def initialize(friendly_name:, code:, locale:, country_code:, template: :default)
    @friendly_name = friendly_name
    @code = code
    @locale = locale
    @country_code = country_code
    @template = template
  end

  def render_message
    lookup_translation(:message, code:, friendly_name:)
  end

  def render_voice_twiml
    Twilio::TwiML::VoiceResponse.new do |response|
      response.say(
        language: lookup_twiml_language,
        message: lookup_translation(:call, friendly_name:, code: code_with_punctuation)
      )
    end.to_xml
  end

  private

  def code_with_punctuation
    code.chars.join(". ")
  end

  def lookup_translation(*keys, **interpolations)
    key = :"verification_templates.#{template}.#{keys.join('.')}"
    fallback = I18n.t(key, **interpolations)
    I18n.t(key, locale:, default: fallback, **interpolations)
  end

  def lookup_twiml_language
    preferred_voice = TTSVoices::Voice.all.find do |voice|
      voice.language.casecmp(locale.to_s).zero?
    end
    preferred_voice ||= TTSVoices::Voice.all.find do |voice|
      voice.language.casecmp("#{locale}-#{country_code}").zero?
    end
    preferred_voice ||= TTSVoices::Voice.all.find do |voice|
      voice.language.start_with?(locale.to_s)
    end

    preferred_voice&.language || DEFAULT_VOICE_LANGUAGE
  end
end
