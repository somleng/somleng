# Be sure to restart your server when you modify this file.

# Add new inflection rules using the following format. Inflections
# are locale specific, and you may define rules for as many different
# locales as you wish. All of these examples are active by default:
# ActiveSupport::Inflector.inflections(:en) do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end

# These inflection rules are supported but not enabled by default:
ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.acronym "CDR"
  inflect.acronym "UUID"
  inflect.acronym "JSONAPI"
  inflect.acronym "JSON"
  inflect.acronym "API"
  inflect.acronym "SIP"
  inflect.acronym "CSV"
  inflect.acronym "OTP"
  inflect.acronym "IP"
  inflect.acronym "ID"
  inflect.acronym "ISO"
  inflect.acronym "OAuth"
  inflect.acronym "SHA256"
  inflect.acronym "TXT"
  inflect.acronym "DNS"
  inflect.acronym "SES"
  inflect.acronym "URL"
  inflect.acronym "HTTP"
  inflect.acronym "SMS"
  inflect.acronym "TwiML"
  inflect.acronym "TTS"
  inflect.acronym "LATA"
  inflect.acronym "FIFO"
end
