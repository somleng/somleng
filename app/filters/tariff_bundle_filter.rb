class TariffBundleFilter < ResourceFilter
  class NameFilter < ApplicationFilter
    filter_params do
      optional(:name).value(:string)
    end

    def apply
      return super if filter_params.blank?

      FuzzySearch.new(super, column: :name).apply(filter_params.fetch(:name))
    end
  end

  class TariffPackageIDFilter < ApplicationFilter
    filter_params do
      optional(:tariff_package_id).value(:string)
    end

    def apply
      return super if filter_params.blank?

      super.joins(:tariff_packages).where(tariff_packages: { id: filter_params.fetch(:tariff_package_id) })
    end
  end

  filter_with(
    NameFilter,
    TariffPackageIDFilter,
    :date_filter
  )
end
