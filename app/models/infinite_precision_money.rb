class InfinitePrecisionMoney < Money
  self.default_infinite_precision = true

  class Formatter < Money::Formatter
    private

    def format_decimal_part(value)
      return nil if currency.decimal_places == 0 && !money.class.default_infinite_precision
      return nil if rules[:no_cents]
      return nil if rules[:no_cents_if_whole] && value.to_i == 0

      # Pad value, making up for missing zeroes at the end
      value = value.ljust(currency.decimal_places, "0")

      # Drop trailing zeros if needed
      value.gsub!(/0*$/, "") if rules[:drop_trailing_zeros]

      value.empty? ? nil : value
    end
  end

  def format(...)
    Formatter.new(self, ...).to_s
  end
end
