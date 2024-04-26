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

  filter_with(
    AssignedFilter,
    :enabled_filter,
    :phone_number_type_filter,
    { country_filter: { attribute_name: :iso_country_code } },
    :number_filter,
    :date_filter
  )
end
