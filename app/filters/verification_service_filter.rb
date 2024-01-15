class VerificationServiceFilter < ResourceFilter
  filter_with :account_id_filter, :name_filter, :date_filter
end
