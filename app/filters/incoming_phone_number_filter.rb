class IncomingPhoneNumberFilter < ResourceFilter
  filter_with(
    :number_filter,
    :account_id_filter,
    :date_filter
  )
end
