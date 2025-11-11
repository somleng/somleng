class TariffPackageFilter < ResourceFilter
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

      super.joins(:tariff_plans).where(tariff_plans: { id: filter_params.fetch(:tariff_plan_id) })
    end
  end

  filter_with(
    NameFilter,
    TariffPlanIDFilter,
    :date_filter
  )
end
