class DestinationTariffFilter < ResourceFilter
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
    DestinationGroupIDFilter,
    :date_filter
  )
end
