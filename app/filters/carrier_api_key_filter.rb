class CarrierAPIKeyFilter < ResourceFilter
  filter_with(
    :access_token_active_filter,
    :id_filter,
    :date_filter
  )
end
