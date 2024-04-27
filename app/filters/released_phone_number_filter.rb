class ReleasedPhoneNumberFilter < ResourceFilter
  filter_with(
    :number_filter,
    { date_filter: { timestamp_column: :released_at } }
  )
end
