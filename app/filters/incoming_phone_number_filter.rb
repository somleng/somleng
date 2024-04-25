class IncomingPhoneNumberFilter < ResourceFilter
  filter_with(
    :number_filter,
    :date_filter
  )
end
