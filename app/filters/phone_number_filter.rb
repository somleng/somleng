class PhoneNumberFilter < ResourceFilter
  class AssignedFilter < ApplicationFilter
    filter_params do
      optional(:assigned).value(:bool)
    end

    def apply
      return super if filter_params.blank?

      if filter_params.fetch(:assigned)
        super.assigned
      else
        super.unassigned
      end
    end
  end

  class VisibilityFilter < ApplicationFilter
    filter_params do
      optional(:visibility).value(:string, included_in?: PhoneNumber.visibility.values)
    end

    def apply
      return super if filter_params.blank?

      super.where(visibility: filter_params.fetch(:visibility))
    end
  end

  class AreaCodeFilter < ApplicationFilter
    filter_params do
      optional(:area_code).value(:string)
    end

    def apply
      return super if filter_params.blank?

      super.where(area_code: filter_params.fetch(:area_code))
    end
  end

  filter_with(
    AssignedFilter,
    VisibilityFilter,
    AreaCodeFilter,
    :phone_number_type_filter,
    { country_filter: { attribute_name: :iso_country_code } },
    :number_filter,
    :date_filter
  )
end
