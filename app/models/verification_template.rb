class VerificationTemplate
  DEFAULT_VOICE_LANGUAGE = "en-US".freeze
  LOCALE_TO_VOICE_LANGUAGE_MAPPING = {
    zh: :cmn,
    "zh-cn": :cmn,
    "zh-hk": :yue,
    ar: :arb
  }.freeze

  attr_reader :friendly_name, :code, :locale, :country_code, :template

  def initialize(friendly_name:, code:, locale:, country_code: "US", template: :default)
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
        language: lookup_voice_language,
        message: lookup_translation(:call, friendly_name:, code: code_with_punctuation)
      )
    end.to_xml
  end

  private

  def code_with_punctuation
    code.chars.join(", ")
  end

  def lookup_translation(*keys, **interpolations)
    key = :"verification_templates.#{template}.#{keys.join('.')}"
    fallback = I18n.t(key, **interpolations)
    I18n.t(key, locale:, default: fallback, **interpolations)
  end

  def lookup_voice_language
    lookup_locale = LOCALE_TO_VOICE_LANGUAGE_MAPPING.fetch(locale, locale).to_s
    preferred_voice = find_tts_voice(locale)
    preferred_voice ||= find_tts_voice("#{locale}-#{country_code}")
    preferred_voice ||= find_tts_voice(lookup_locale)
    preferred_voice ||= find_tts_voice("#{lookup_locale}-#{country_code}")
    preferred_voice ||= find_tts_voice { |language| language.start_with?(lookup_locale) }
    preferred_voice&.language || DEFAULT_VOICE_LANGUAGE
  end

  def find_tts_voice(language = nil, &block)
    TTSVoices::Voice.all.find do |voice|
      block_given? ? yield(voice.language) : voice.language.casecmp(language.to_s).zero?
    end
  end
end
