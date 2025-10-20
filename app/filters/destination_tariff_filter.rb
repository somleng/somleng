class DestinationTariffFilter < ResourceFilter
  class CategoryFilter < ApplicationFilter
    filter_params do
      optional(:category).value(:string, included_in?: Tariff.category.values)
    end

    def apply
      return super if filter_params.blank?

      super.joins(:tariff).where(tariffs: { category: filter_params.fetch(:category) })
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

  class TariffIDFilter < ApplicationFilter
    filter_params do
      optional(:tariff_id).value(:string)
    end

    def apply
      return super if filter_params.blank?

      super.where(tariff_id: filter_params.fetch(:tariff_id))
    end
  end

  class DestinationGroupIDFilter < ApplicationFilter
    filter_params do
      optional(:destination_group_id).value(:string)
    end

    def apply
      return super if filter_params.blank?

      super.where(destination_group_id: filter_params.fetch(:destination_group_id))
    end
  end

  filter_with(
    CategoryFilter,
    TariffScheduleIDFilter,
    TariffIDFilter,
    DestinationGroupIDFilter,
    :date_filter
  )
end
