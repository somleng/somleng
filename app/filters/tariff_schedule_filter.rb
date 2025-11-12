class TariffScheduleFilter < ResourceFilter
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

  class TariffPlanIDFilter < ApplicationFilter
    filter_params do
      optional(:tariff_plan_id).value(:string)
    end

    def apply
      return super if filter_params.blank?

      super.joins(:plans).where(tariff_plans: { id: filter_params.fetch(:tariff_plan_id) })
    end
  end

  class DestinationGroupIDFilter < ApplicationFilter
    filter_params do
      optional(:destination_group_id).value(:string)
    end

    def apply
      return super if filter_params.blank?

      super.joins(:destination_groups).where(destination_groups: { id: filter_params.fetch(:destination_group_id) })
    end
  end

  filter_with(
    CategoryFilter,
    NameFilter,
    TariffPlanIDFilter,
    DestinationGroupIDFilter,
    :date_filter
  )
end
