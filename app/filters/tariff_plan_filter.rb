class TariffPlanFilter < ResourceFilter
  class CategoryFilter < ApplicationFilter
    filter_params do
      optional(:category).value(:string, included_in?: TariffPackage.category.values)
    end

    def apply
      return super if filter_params.blank?

      super.joins(:tariff_package).where(tariff_packages: { category: filter_params.fetch(:category) })
    end
  end


  class TariffPackageIDFilter < ApplicationFilter
    filter_params do
      optional(:tariff_package_id).value(:string)
    end

    def apply
      return super if filter_params.blank?

      super.where(tariff_package_id: filter_params.fetch(:tariff_package_id))
    end
  end

  class TariffScheduleIDFilter < ApplicationFilter
    filter_params do
      optional(:tariff_schedule_id).value(:string)
    end

    def apply
      return super if filter_params.blank?

      super.where(tariff_schedule_id: filter_params.fetch(:tariff_schedule_id))
    end
  end

  filter_with(
    CategoryFilter,
    TariffScheduleIDFilter,
    TariffPackageIDFilter,
    :date_filter
  )
end
