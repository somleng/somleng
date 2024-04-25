class PhoneNumberFilter < ResourceFilter
  filter_with(
    :enabled_filter,
    :phone_number_type_filter,
    { country_filter: { attribute_name: :iso_country_code } },
    :number_filter,
    :date_filter
  )
end
