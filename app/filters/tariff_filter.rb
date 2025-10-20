class TariffFilter < ResourceFilter
  class NameFilter < ApplicationFilter
    filter_params do
      optional(:name).value(:string)
    end

    def apply
      return super if filter_params.blank?

      FuzzySearch.new(super, column: :name).apply(filter_params.fetch(:name))
    end
  end

  class CategoryFilter < ApplicationFilter
    filter_params do
      optional(:category).value(:string, included_in?: Tariff.category.values)
    end

    def apply
      return super if filter_params.blank?

      super.where(category: filter_params.fetch(:category))
    end
  end

  filter_with(
    NameFilter,
    CategoryFilter,
    :date_filter
  )
end
