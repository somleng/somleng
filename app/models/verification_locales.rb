class VerificationLocales
  Locale = Struct.new(:iso_code, :language_name, keyword_init: true)
  CountryLocale = Struct.new(:country_code, :locale, keyword_init: true)

  DEFAULT_COUNTRY_LOCALE = CountryLocale.new(country_code: "US", locale: "en").freeze

  COUNTRY_LOCALES = [
    CountryLocale.new(country_code: "AD", locale: "ca"),
    CountryLocale.new(country_code: "AE", locale: "ar"),
    CountryLocale.new(country_code: "AO", locale: "pt"),
    CountryLocale.new(country_code: "AT", locale: "de"),
    CountryLocale.new(country_code: "AW", locale: "nl"),
    CountryLocale.new(country_code: "AX", locale: "sv"),
    CountryLocale.new(country_code: "BH", locale: "ar"),
    CountryLocale.new(country_code: "BJ", locale: "fr"),
    CountryLocale.new(country_code: "BL", locale: "fr"),
    CountryLocale.new(country_code: "BN", locale: "ms"),
    CountryLocale.new(country_code: "BR", locale: "pt"),
    CountryLocale.new(country_code: "CI", locale: "fr"),
    CountryLocale.new(country_code: "CL", locale: "es"),
    CountryLocale.new(country_code: "CN", locale: "zh"),
    CountryLocale.new(country_code: "CO", locale: "es"),
    CountryLocale.new(country_code: "CR", locale: "es"),
    CountryLocale.new(country_code: "CU", locale: "es"),
    CountryLocale.new(country_code: "CV", locale: "pt"),
    CountryLocale.new(country_code: "CW", locale: "nl"),
    CountryLocale.new(country_code: "DE", locale: "de"),
    CountryLocale.new(country_code: "DK", locale: "da"),
    CountryLocale.new(country_code: "DO", locale: "es"),
    CountryLocale.new(country_code: "DZ", locale: "ar"),
    CountryLocale.new(country_code: "EC", locale: "es"),
    CountryLocale.new(country_code: "EG", locale: "ar"),
    CountryLocale.new(country_code: "ES", locale: "es"),
    CountryLocale.new(country_code: "FR", locale: "fr"),
    CountryLocale.new(country_code: "GA", locale: "fr"),
    CountryLocale.new(country_code: "GF", locale: "fr"),
    CountryLocale.new(country_code: "GR", locale: "el"),
    CountryLocale.new(country_code: "GT", locale: "es"),
    CountryLocale.new(country_code: "GW", locale: "pt"),
    CountryLocale.new(country_code: "HN", locale: "es"),
    CountryLocale.new(country_code: "HR", locale: "hr"),
    CountryLocale.new(country_code: "HU", locale: "hu"),
    CountryLocale.new(country_code: "ID", locale: "id"),
    CountryLocale.new(country_code: "IQ", locale: "ar"),
    CountryLocale.new(country_code: "IT", locale: "it"),
    CountryLocale.new(country_code: "JO", locale: "ar"),
    CountryLocale.new(country_code: "JP", locale: "ja"),
    CountryLocale.new(country_code: "KH", locale: "km"),
    CountryLocale.new(country_code: "KP", locale: "ko"),
    CountryLocale.new(country_code: "KR", locale: "ko"),
    CountryLocale.new(country_code: "KW", locale: "ar"),
    CountryLocale.new(country_code: "LI", locale: "de"),
    CountryLocale.new(country_code: "LT", locale: "lt"),
    CountryLocale.new(country_code: "LY", locale: "ar"),
    CountryLocale.new(country_code: "MA", locale: "ar"),
    CountryLocale.new(country_code: "MC", locale: "fr"),
    CountryLocale.new(country_code: "MD", locale: "ro"),
    CountryLocale.new(country_code: "ML", locale: "fr"),
    CountryLocale.new(country_code: "MQ", locale: "fr"),
    CountryLocale.new(country_code: "MX", locale: "es"),
    CountryLocale.new(country_code: "MZ", locale: "pt"),
    CountryLocale.new(country_code: "NC", locale: "fr"),
    CountryLocale.new(country_code: "NE", locale: "fr"),
    CountryLocale.new(country_code: "NI", locale: "es"),
    CountryLocale.new(country_code: "NL", locale: "nl"),
    CountryLocale.new(country_code: "NO", locale: "nb"),
    CountryLocale.new(country_code: "OM", locale: "ar"),
    CountryLocale.new(country_code: "PA", locale: "es"),
    CountryLocale.new(country_code: "PE", locale: "es"),
    CountryLocale.new(country_code: "PF", locale: "fr"),
    CountryLocale.new(country_code: "PL", locale: "pl"),
    CountryLocale.new(country_code: "PM", locale: "fr"),
    CountryLocale.new(country_code: "PT", locale: "pt"),
    CountryLocale.new(country_code: "QA", locale: "ar"),
    CountryLocale.new(country_code: "RE", locale: "fr"),
    CountryLocale.new(country_code: "RO", locale: "ro"),
    CountryLocale.new(country_code: "RU", locale: "ru"),
    CountryLocale.new(country_code: "SA", locale: "ar"),
    CountryLocale.new(country_code: "SE", locale: "sv"),
    CountryLocale.new(country_code: "SK", locale: "sk"),
    CountryLocale.new(country_code: "SM", locale: "it"),
    CountryLocale.new(country_code: "SN", locale: "fr"),
    CountryLocale.new(country_code: "SR", locale: "nl"),
    CountryLocale.new(country_code: "ST", locale: "pt"),
    CountryLocale.new(country_code: "SV", locale: "es"),
    CountryLocale.new(country_code: "SY", locale: "ar"),
    CountryLocale.new(country_code: "TG", locale: "fr"),
    CountryLocale.new(country_code: "TH", locale: "th"),
    CountryLocale.new(country_code: "TL", locale: "pt"),
    CountryLocale.new(country_code: "TR", locale: "tr"),
    CountryLocale.new(country_code: "TW", locale: "zh"),
    CountryLocale.new(country_code: "UA", locale: "uk"),
    CountryLocale.new(country_code: "UY", locale: "es"),
    CountryLocale.new(country_code: "VE", locale: "es"),
    CountryLocale.new(country_code: "VN", locale: "vi"),
    CountryLocale.new(country_code: "WF", locale: "fr"),
    CountryLocale.new(country_code: "YE", locale: "ar")
  ].freeze

  class << self
    def available_locales
      @available_locales ||= begin
        iso_codes = I18n.available_locales.select do |locale|
          I18n.t(:"verification_templates.default", locale:, default: nil).present?
        end

        iso_codes.map do |iso_code|
          Locale.new(iso_code:, language_name: I18n.t!(:language_name, locale: iso_code))
        end
      end
    end

    def find_by_country(country)
      COUNTRY_LOCALES.find(-> { DEFAULT_COUNTRY_LOCALE }) do |locale|
        locale.country_code == country.alpha2
      end
    end
  end
end
