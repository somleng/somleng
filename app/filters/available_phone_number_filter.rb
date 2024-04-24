class AvailablePhoneNumberFilter < ResourceFilter
  filter_with(
    :phone_number_type_filter,
    { country_filter: { attribute_name: :iso_country_code } },
    :number_filter,
    :currency_filter
  )
end
