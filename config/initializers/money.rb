MoneyRails.configure do |config|
  # See also https://github.com/RubyMoney/money-rails#configuration-parameters

  # Register a custom currency to handle fractional cents
  config.register_currency = {
    :priority            => 1,
    :iso_code            => "USD6",
    :name                => "United States Dollar with subunit of 6 digits",
    :symbol              => "$",
    :symbol_first        => true,
    :subunit             => "MicroDollar",
    :subunit_to_unit     => 1000000,
    :thousands_separator => ",",
    :decimal_mark        => ".",
    :smallest_denomination => 1
  }

  config.add_rate("USD6", "USD", 1)
end
