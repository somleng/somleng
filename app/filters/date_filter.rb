class DateFilter < ApplicationFilter
  filter_params do
    optional(:from_date).value(:date)
    optional(:to_date).value(:date)
  end

  def apply
    return super if filter_params.blank?

    date_range = Range.new(
      filter_params.fetch(:from_date).beginning_of_day,
      filter_params.fetch(:to_date).end_of_day
    )
    super.where(created_at: date_range)
  end
end
