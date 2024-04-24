class AvailablePhoneNumberFilter < ResourceFilter
  filter_with(
    :phone_number_type_filter,
    :country_filter,
    :number_filter,
    :currency_filter
  )
end
