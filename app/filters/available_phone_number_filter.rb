class AvailablePhoneNumberFilter < ResourceFilter
  filter_with(
    :phone_number_type_filter,
    :area_code_filter,
    :region_filter,
    :locality_filter,
    { country_filter: { attribute_name: :iso_country_code } },
    :number_filter
  )
end
