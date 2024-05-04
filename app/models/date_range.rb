class DateRange
  attr_reader :from_date, :to_date

  def initialize(from_date:, to_date:)
    @from_date = from_date
    @to_date = to_date
  end

  def to_range
    Range.new(from_date, to_date + 1.day)
  end

  def valid?
    return false if empty?
    return true if to_date.blank? || from_date.blank?

    to_date >= from_date
  end

  private

  def empty?
    from_date.blank? && to_date.blank?
  end
end
