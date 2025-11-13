class TariffPlanFilter < ResourceFilter
  class CategoryFilter < ApplicationFilter
    filter_params do
      optional(:category).value(:string, included_in?: TariffSchedule.category.values)
    end

    def apply
      return super if filter_params.blank?

      super.where(category: filter_params.fetch(:category))
    end
  end

  class NameFilter < ApplicationFilter
    filter_params do
      optional(:name).value(:string)
    end

    def apply
      return super if filter_params.blank?

      FuzzySearch.new(super, column: :name).apply(filter_params.fetch(:name))
    end
  end

  class TariffScheduleIDFilter < ApplicationFilter
    filter_params do
      optional(:tariff_schedule_id).value(:string)
    end

    def apply
      return super if filter_params.blank?

      super.joins(:schedules).where(tariff_schedules: { id: filter_params.fetch(:tariff_schedule_id) })
    end
  end

  filter_with(
    CategoryFilter,
    NameFilter,
    TariffScheduleIDFilter,
    :date_filter
  )
end
