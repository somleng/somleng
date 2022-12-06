class DateRangeParser
  def parse(from_date, to_date)
    Range.new(from_date, to_date.change(usec: Rational(999_999_999, 1000)))
  end
end
