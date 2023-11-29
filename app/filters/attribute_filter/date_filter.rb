module AttributeFilter
  class DateFilter < ApplicationFilter
    filter_params do
      optional(:from_date).value(:date)
      optional(:to_date).value(:date)
    end

    def apply
      date_range = DateRange.new(
        from_date: filter_params[:from_date],
        to_date: filter_params[:to_date]
      )

      return super unless date_range.valid?

      super.where(created_at: date_range.to_range)
    end
  end
end
