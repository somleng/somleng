MoneyRails.configure do |config|
  config.rounding_mode = BigDecimal::ROUND_HALF_UP
  config.locale_backend = :i18n
end
