class TariffScheduleFilter < ResourceFilter
  class NameFilter < ApplicationFilter
    filter_params do
      optional(:name).value(:string)
    end

    def apply
      return super if filter_params.blank?

      FuzzySearch.new(super, column: :name).apply(filter_params.fetch(:name))
    end
  end

  filter_with(
    NameFilter,
    :date_filter
  )
end
