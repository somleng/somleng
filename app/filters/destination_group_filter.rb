class DestinationGroupFilter < ResourceFilter
  class NameFilter < ApplicationFilter
    filter_params do
      optional(:name).value(:string)
    end

    def apply
      return super if filter_params.blank?
      name = filter_params.fetch(:name).squish

      super.where(DestinationGroup.arel_table[:name].matches("%#{name}%", nil, true))
    end
  end

  filter_with(
    NameFilter,
    :date_filter
  )
end
