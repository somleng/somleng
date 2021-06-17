class PhoneNumberFilter < ResourceFilter
  filter_with AccountIdFilter, DateFilter
end
